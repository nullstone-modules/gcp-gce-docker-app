output "cloud_init_stanzas" {
  value = [
    { content = local.cloud_init_content }
  ]
}

output "env" {
  value = [for k, v in var.app_env : { name = k, value = v }]
}

# Declare existing GSM secrets so gcp-gce-server grants per-secret secretAccessor
# (never project-wide). Values use secret() refs — no secret material in TF state.
output "secrets" {
  value = concat(
    [
      for env_name, secret_id in var.secret_names : {
        name  = env_name
        value = "{{ secret(\"${secret_id}\") }}"
      }
    ],
    [
      for secret_id in var.hostkey_secret_names : {
        name  = "HOSTKEY_${replace(secret_id, "-", "_")}"
        value = "{{ secret(\"${secret_id}\") }}"
      }
    ]
  )
}
