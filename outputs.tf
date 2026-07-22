output "cloud_init_stanzas" {
  value = [
    { content = local.cloud_init_content }
  ]
}

output "env" {
  value = [for k, v in var.app_env : { name = k, value = v }]
}

# Declare existing GSM env/password secrets so gcp-gce-server grants per-secret
# secretAccessor (never project-wide) and its loader resolves them into app.env.
# Values use secret() refs, so no secret material enters Terraform state.
#
# Host keys are intentionally NOT listed here: they must be files, not env vars,
# so they are materialized to the tmpfs mount by secrets-init.sh in this module.
# The VM service account still needs secretAccessor on each host-key secret;
# grant that out of band (see README).
output "secrets" {
  value = [
    for env_name, secret_id in var.secret_names : {
      name  = env_name
      value = "{{ secret(\"${secret_id}\") }}"
    }
  ]
}
