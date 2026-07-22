#!/usr/bin/env bash
#
# secrets-init.sh
#
# Materializes SSH host-key files for the application.
#
# Environment variables and password secrets are provided separately by the
# server module (gcp-gce-server), which writes ${secrets_mount}/app.env at boot.
# This script only handles secrets that must exist as files rather than
# environment variables (SSH host keys), fetching each from Secret Manager into
# the tmpfs mount.
#
# gcloud is not installed on Container-Optimized OS, so the fetch runs inside
# the google/cloud-sdk:slim container, which inherits the VM service account
# credentials from the metadata server.

set -euo pipefail

mkdir -p ${secrets_mount}
grep -q "${secrets_mount}" /proc/mounts || mount -t tmpfs -o size=1m tmpfs ${secrets_mount}

%{ if length(hostkey_secret_names) > 0 ~}
docker run --rm \
  -v ${secrets_mount}:/out \
  google/cloud-sdk:slim \
  bash -c '
set -euo pipefail
umask 077
%{ for secret_name in hostkey_secret_names ~}
gcloud secrets versions access latest --secret=${secret_name} > /out/${secret_name}
chmod 644 /out/${secret_name}
%{ endfor ~}
'
%{ endif ~}
echo "secrets-init: ok"
