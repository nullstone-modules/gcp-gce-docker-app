variable "app_metadata" {
  description = <<EOD
Nullstone automatically injects metadata from the app module into this module through this variable.
This variable is a reserved variable for capabilities.
EOD

  type    = map(string)
  default = {}
}

locals {
  data_dir      = var.app_metadata["data_dir"]
  secrets_mount = var.app_metadata["secrets_mount"]
}

variable "image_url" {
  type        = string
  description = "Container image to run"
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
    host_ip        = optional(string, "0.0.0.0")
    host_port      = number
    container_port = number
  }))
  default     = []
  description = <<EOD
Ports to publish from the container to the VM.
Each entry becomes a `docker run -p <host_ip>:<host_port>:<container_port>` flag.

Example:
```
ports = [
  { host_port = 2222, container_port = 22 },
  { host_ip = "127.0.0.1", host_port = 8080, container_port = 80 },
]
```
EOD
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
Each entry becomes a `docker run -v <src>:<target>[:ro]` flag; mounts are read-only
unless `read_only = false`.

Example:
```
volumes = [
  { src = "/var/lib/myapp/secrets/ssh_host_ed25519_key", target = "/etc/ssh/ssh_host_ed25519_key" },
  { src = "/var/lib/myapp/data", target = "/data", read_only = false },
]
```
EOD
}
