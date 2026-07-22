#!/usr/bin/env bash
set -euo pipefail

mkdir -p ${secrets_mount}
grep -q "${secrets_mount}" /proc/mounts || mount -t tmpfs -o size=1m tmpfs ${secrets_mount}

docker run --rm \
  -v ${secrets_mount}:/out \
  google/cloud-sdk:slim \
  bash -c '
set -euo pipefail
umask 077
: > /out/app.env
%{ for env_name, secret_name in secret_names ~}
echo "${env_name}=$(gcloud secrets versions access latest --secret=${secret_name})" >> /out/app.env
%{ endfor ~}
%{ for secret_name in hostkey_secret_names ~}
gcloud secrets versions access latest --secret=${secret_name} > /out/${secret_name}
chmod 644 /out/${secret_name}
%{ endfor ~}
echo "secrets-init: ok"
'
