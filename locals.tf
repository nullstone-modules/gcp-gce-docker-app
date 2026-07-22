locals {
  secrets_init_sh = templatefile("${path.module}/templates/secrets-init.sh.tpl", {
    secret_names         = var.secret_names
    hostkey_secret_names = var.hostkey_secret_names
    secrets_mount        = var.secrets_mount
  })

  docker_app_service = templatefile("${path.module}/templates/docker-app.service.tpl", {
    container_name = var.container_name
  })

  docker_up_sh = <<-EOT
#!/usr/bin/env bash
set -euo pipefail
/usr/local/bin/secrets-init.sh
test -s ${var.secrets_mount}/app.env || { echo "secrets missing, refusing to start"; exit 1; }
docker rm -f ${var.container_name} 2>/dev/null || true
docker run -d --name ${var.container_name} --restart unless-stopped \
  --env-file ${var.secrets_mount}/app.env \
  ${join(" ", [for k, v in var.app_env : "-e ${k}=\"${v}\""])} \
  -v ${var.secrets_mount}:${var.secrets_mount}:ro \
  -v ${var.data_dir}:${var.data_dir} \
  ${join(" ", [for p in var.ports : "-p ${p.host_ip}:${p.published}:${p.target}"])} \
  ${var.image_url}
EOT

  cloud_init_content = {
    write_files = [
      {
        path        = "/usr/local/bin/secrets-init.sh"
        permissions = "0755"
        owner       = "root:root"
        content     = local.secrets_init_sh
      },
      {
        path        = "/usr/local/bin/docker-app-up.sh"
        permissions = "0755"
        owner       = "root:root"
        content     = local.docker_up_sh
      },
      {
        path        = "/etc/systemd/system/docker-app.service"
        permissions = "0644"
        owner       = "root:root"
        content     = local.docker_app_service
      },
    ]
    runcmd = [
      "systemctl daemon-reload",
      "systemctl enable --now docker-app.service",
    ]
  }
}
