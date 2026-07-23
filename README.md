# gcp-gce-docker-app

Nullstone capability that runs a Docker container on a `gcp-gce-server` instance
(Container-Optimized OS).

## How it works

`gcp-gce-server` installs `load-app-secrets.sh` and writes env/secret manifests.
This capability:

1. Re-runs the server loader on every `docker-app` start (tmpfs clears on reboot).
2. Materializes SSH host-key **files** into the tmpfs secrets mount.
3. Starts the container with `--env-file /run/app-secrets/app.env` (plain
   `docker run` + systemd; no Compose plugin).

## Requirements

- Docker-capable image (COS recommended).
- VM service account needs `secretAccessor` on each **host-key** secret
  (env/password secrets are granted by the server module). Example:

```bash
gcloud secrets add-iam-policy-binding HOSTKEY_SECRET_NAME \
  --member="serviceAccount:VM_SERVICE_ACCOUNT" \
  --role="roles/secretmanager.secretAccessor" \
  --project=PROJECT_ID
```

## Inputs

See `variables.tf`: `image_url` (required), `ports`, `app_env`, `secret_names`,
`hostkey_secret_names`, `container_name`, `data_dir`, `secrets_mount`.
