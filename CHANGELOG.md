# Changelog

### 0.1.0 (Unreleased)

- Add `cloud_init_stanzas` Docker bootstrap for Container-Optimized OS
  (tmpfs secrets, plain `docker run`, systemd).
- Delegate env/password secret loading to `gcp-gce-server`; this capability
  materializes SSH host-key files and starts the container with
  `--env-file /run/app-secrets/app.env`.
- Re-run `/app/load-app-secrets.sh` on every service start so `app.env`
  is rematerialized after reboot (tmpfs is cleared).
- Emit unquoted `{{ secret(<id>) }}` refs for server IAM and the app.env loader.
- Package `templates/*` via `.nullstone/module.yml`.
