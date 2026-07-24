# gcp-gce-docker-app

Nullstone capability that runs a Docker container on a `gcp-gce-server` instance
(Container-Optimized OS) as a systemd service.

## How it works

`gcp-gce-server` owns all environment variables and secrets. Per the server
contract, it writes `app.env` (and any secret files) to a known tmpfs path
(`/run/app-secrets` by default). This capability only:

1. Re-runs the server loader on every service start (tmpfs clears on reboot).
2. Starts the container as `<container_name>.service` with
   `--env-file /run/app-secrets/app.env` (plain `docker run` + systemd).

The secrets mount is bind-mounted read-only into the container. Use `volumes` to
map specific host paths (for example SSH host keys) to app-specific container
paths.

## Requirements

- A Docker-capable image (Container-Optimized OS recommended).

Secret access (IAM) is handled by `gcp-gce-server`; this capability requires no
`secretAccessor` grants.

## Inputs

See `variables.tf`: `image_url` (required), `container_name`, `ports`, `volumes`.
`data_dir` and `secrets_mount` are injected by `gcp-gce-server` via `app_metadata`
(not user-configurable).

Example host-key volume mounts:

```yaml
volumes:
  - src: "/run/app-secrets/id_ed25519"
    target: "/etc/sftpgo/id_ed25519"
  - src: "/run/app-secrets/id_rsa"
    target: "/etc/sftpgo/id_rsa"
```
