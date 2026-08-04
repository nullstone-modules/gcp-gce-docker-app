locals {
  # Systemd service is named after the container so admins run `systemctl status <container_name>`.
  service_name = "${var.container_name}.service"

  # COS: keep app helpers under /etc/apps/<name> (writable + executable).
  # Units stay in the standard systemd path; server built-ins stay in /etc/nullstone.
  app_dir       = "/etc/apps/${var.container_name}"
  nullstone_dir = "/etc/nullstone"

  docker_app_service = templatefile("${path.module}/templates/docker-app.service.tpl", {
    container_name = var.container_name
    app_dir        = local.app_dir
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
  #
  # docker pull retries: private-subnet VMs use Cloud NAT; on first boot / MIG
  # replace, NAT can lag and a single pull times out (~15s). Fail closed only
  # after retries are exhausted. Secrets stay fail-closed with no retry.
  docker_up_sh = <<-EOT
#!/usr/bin/env bash
set -euo pipefail
${local.nullstone_dir}/load-app-secrets.sh
test -s ${local.secrets_mount}/app.env || { echo "app.env missing (server secret loader did not run); refusing to start"; exit 1; }

image='${var.image_url}'
pull_attempts=12
pull_delay_sec=5
for attempt in $(seq 1 "$pull_attempts"); do
  if docker pull "$image"; then
    break
  fi
  if [ "$attempt" -eq "$pull_attempts" ]; then
    echo "docker pull failed after $${pull_attempts} attempts: $image" >&2
    exit 1
  fi
  echo "docker pull attempt $attempt/$${pull_attempts} failed; retrying in $${pull_delay_sec}s..." >&2
  sleep "$pull_delay_sec"
done

docker rm -f ${var.container_name} 2>/dev/null || true
docker run -d --name ${var.container_name} --restart unless-stopped \
  --env-file ${local.secrets_mount}/app.env \
  -v ${local.secrets_mount}:${local.secrets_mount}:ro \
  -v ${local.data_dir}:${local.data_dir} \
  ${local.volume_flags} \
  ${local.port_flags} \
  "$image"
EOT

  cloud_init_write_files = [
    {
      path        = "${local.app_dir}/docker-app-up.sh"
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
