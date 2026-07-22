# gcp-gce-docker-app

A Nullstone capability that runs a Docker container on a `gcp-gce-server`
instance.

### How it works

The server module (`gcp-gce-server`) aggregates environment variables and
password secrets and writes them to a tmpfs file, `/run/app-secrets/app.env`,
at boot. This capability builds on that:

- It materializes SSH host-key files into the tmpfs secrets mount, because host
  keys must exist as files rather than environment variables.
- It runs the container with `--env-file /run/app-secrets/app.env`, publishes
  the configured ports, and mounts the data directory.

### Requirements

- A docker-capable image. Use Container-Optimized OS (COS); Docker is
  preinstalled and no package installation happens in the boot path.
- The VM service account needs `secretAccessor` on each host-key secret. The
  env and password secrets are granted by the server module, but host keys are
  materialized here, so grant host-key access out of band. For example:

      gcloud secrets add-iam-policy-binding HOSTKEY_SECRET_NAME \
        --member="serviceAccount:VM_SERVICE_ACCOUNT" \
        --role="roles/secretmanager.secretAccessor" \
        --project=PROJECT_ID

### Inputs

See `variables.tf`: `image_url` (required), `ports`, `app_env`, `secret_names`,
`hostkey_secret_names`, `container_name`, `data_dir`, `secrets_mount`.
