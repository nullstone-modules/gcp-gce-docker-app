variable "app_metadata" {
  description = <<EOF
Nullstone injects metadata from the parent app module through this reserved variable.
EOF

  type    = map(string)
  default = {}
}

variable "image_url" {
  type        = string
  description = "Container image to run (for example ghcr.io/drakkan/sftpgo:v2.6)."
}

variable "container_name" {
  type        = string
  default     = "app"
  description = "Docker container name."
}

variable "ports" {
  type = list(object({
    published = number
    target    = number
    host_ip   = optional(string, "0.0.0.0")
  }))
  default     = []
  description = "Host ports to publish. Bind admin UIs to 127.0.0.1."
}

variable "app_env" {
  type        = map(string)
  default     = {}
  description = "Non-sensitive container env vars (exported via the env capability output)."
}

variable "secret_names" {
  type        = map(string)
  default     = {}
  description = "ENV_VAR => existing GSM secret id. Exported as secret() refs for server IAM and app.env loading."
}

variable "hostkey_secret_names" {
  type        = list(string)
  default     = []
  description = "GSM secret ids for SSH host-key files written into the tmpfs secrets mount."
}

variable "data_dir" {
  type        = string
  default     = "/var/lib/app"
  description = "Persistent host directory mounted into the container."
}

variable "secrets_mount" {
  type        = string
  default     = "/run/app-secrets"
  description = "Tmpfs mount for secrets (RAM only; never on the boot disk)."
}
