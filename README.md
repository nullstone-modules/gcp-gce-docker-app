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

The secrets mount is bind-mounted read-only into the container, so any secret
files the server places there (for example SSH host keys) are visible to the app.

## Requirements

- A Docker-capable image (Container-Optimized OS recommended).

Secret access (IAM) is handled by `gcp-gce-server`; this capability requires no
`secretAccessor` grants.

## Inputs

See `variables.tf`: `image_url` (required), `container_name`, `ports`,
`data_dir`, `secrets_mount`.
