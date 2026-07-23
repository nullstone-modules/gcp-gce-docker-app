output "cloud_init_stanzas" {
  description = "Cloud-init write_files and runcmd for the parent gcp-gce-server module."
  value = [
    { content = local.cloud_init_content }
  ]
}

output "env" {
  description = "Non-sensitive environment variables merged into the server app env."
  value       = [for k, v in var.app_env : { name = k, value = v }]
}

# Env/password secrets only. Host keys are files (see secrets-init.sh), not env vars,
# so they are omitted here; grant the VM secretAccessor on host-key secrets out of band.
# Use unquoted {{ secret(<id>) }} — quoted forms leave literal " in IAM and manifests.
output "secrets" {
  description = "Existing GSM secret refs for per-secret IAM and the server app.env loader."
  value = [
    for env_name, secret_id in var.secret_names : {
      name  = env_name
      value = "{{ secret(${secret_id}) }}"
    }
  ]
}
