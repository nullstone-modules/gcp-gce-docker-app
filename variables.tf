variable "app_metadata" {
  description = <<EOD
Nullstone automatically injects metadata from the app module into this module through this variable.
This variable is a reserved variable for capabilities.
EOD

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
  description = "Docker container name, also used as the systemd service name for the application."

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]*$", var.container_name))
    error_message = "container_name must be a valid systemd service name: start with a letter or digit and contain only letters, digits, and the characters _ . -"
  }
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

variable "volumes" {
  type = list(object({
    src       = string
    target    = string
    read_only = optional(bool, true)
  }))
  default     = []
  description = <<EOD
Extra bind mounts from the VM host into the container (for example SSH host key
files under SECRETS_MOUNT_DIR mapped to app-specific paths).
EOD
}
