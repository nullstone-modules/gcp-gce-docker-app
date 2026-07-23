#!/usr/bin/env bash
#
# Materialize SSH host-key files into tmpfs.
# Env/password secrets are provided by gcp-gce-server in ${secrets_mount}/app.env.
# COS has no gcloud; fetch via google/cloud-sdk:slim using the VM metadata identity.

set -euo pipefail

mkdir -p "${secrets_mount}"
grep -q "${secrets_mount}" /proc/mounts || mount -t tmpfs -o size=1m tmpfs "${secrets_mount}"

%{ if length(hostkey_secret_names) > 0 ~}
docker run --rm \
  -v "${secrets_mount}:/out" \
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
