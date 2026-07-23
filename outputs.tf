output "cloud_init_stanzas" {
  description = "Cloud-init write_files and runcmd contributed to the parent gcp-gce-server module."
  value = [
    { content = local.cloud_init_content }
  ]
}
