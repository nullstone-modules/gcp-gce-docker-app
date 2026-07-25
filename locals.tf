locals {
  # Systemd service is named after the container so admins run `systemctl status <container_name>`.
  service_name = "${var.container_name}.service"

  docker_app_service = templatefile("${path.module}/templates/docker-app.service.tpl", {
    container_name = var.container_name
  })

  volume_flags = join(" ", [
    for v in var.volumes :
    "-v ${v.src}:${v.target}${v.read_only ? ":ro" : ""}"
  ])

  port_flags = join(" ", [
    for p in var.ports :
    "-p ${p.host_ip}:${p.host_port}:${p.container_port}"
  ])

  # Env/password secrets and any secret files are provided by gcp-gce-server at
  # ${local.secrets_mount} (see README contract). Re-run the server loader on every
  # start because ${local.secrets_mount} is tmpfs and clears on reboot.
  docker_up_sh = <<-EOT
#!/usr/bin/env bash
set -euo pipefail
/app/load-app-secrets.sh
test -s ${local.secrets_mount}/app.env || { echo "app.env missing (server secret loader did not run); refusing to start"; exit 1; }
docker rm -f ${var.container_name} 2>/dev/null || true
docker run -d --name ${var.container_name} --restart unless-stopped \
  --env-file ${local.secrets_mount}/app.env \
  -v ${local.secrets_mount}:${local.secrets_mount}:ro \
  -v ${local.data_dir}:${local.data_dir} \
  ${local.volume_flags} \
  ${local.port_flags} \
  ${var.image_url}
EOT

  cloud_init_write_files = [
    {
      path        = "/app/${var.container_name}/docker-app-up.sh"
      permissions = "0755"
      owner       = "root:root"
      content     = local.docker_up_sh
    },
    {
      path        = "/etc/systemd/system/${local.service_name}"
      permissions = "0644"
      owner       = "root:root"
      content     = local.docker_app_service
    },
  ]
  cloud_init_runcmd = [
    "systemctl daemon-reload",
    "systemctl enable --now ${local.service_name}",
  ]
}
