output "cloud_init_stanzas" {
  description = "Cloud-init write_files and runcmd contributed to the parent gcp-gce-server module."
  value = [
    {
      write_files = local.cloud_init_write_files
      runcmd      = local.cloud_init_runcmd
    }
  ]
}
