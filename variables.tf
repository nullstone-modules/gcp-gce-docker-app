variable "app_metadata" {
  description = <<EOF
Nullstone automatically injects metadata from the app module into this module through this variable.
This variable is a reserved variable for capabilities.
EOF

  type    = map(string)
  default = {}
}

variable "image_url" {
  type        = string
  description = "Container image to run, e.g. ghcr.io/drakkan/sftpgo:v2.6"
}

variable "container_name" {
  type        = string
  default     = "app"
  description = "Docker container name for the application."
}

variable "ports" {
  type = list(object({
    published = number
    target    = number
    host_ip   = optional(string, "0.0.0.0")
  }))
  default     = []
  description = "Ports to publish from the container to the VM."
}

variable "app_env" {
  type        = map(string)
  default     = {}
  description = "Non-sensitive env vars for the container (merged with Nullstone-provided env at the app level)."
}

variable "secret_names" {
  type        = map(string)
  default     = {}
  description = "Map of ENV_VAR_NAME => Secret Manager secret name to fetch at boot into tmpfs."
}

variable "hostkey_secret_names" {
  type        = list(string)
  default     = []
  description = "Secret Manager secret names holding SSH host keys written into tmpfs at boot."
}

variable "data_dir" {
  type        = string
  default     = "/var/lib/app"
  description = "Persistent data directory on the VM mounted into the container."
}

variable "secrets_mount" {
  type        = string
  default     = "/run/app-secrets"
  description = "Tmpfs mount path for secrets fetched at boot (RAM only)."
}
