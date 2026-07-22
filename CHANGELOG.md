# 0.1.0 (Unreleased)

* Add `cloud_init_stanzas` output with a Docker bootstrap for Container-Optimized OS (tmpfs secrets, plain `docker run`, systemd).
* Add variables for image, ports, app env, secret names, host keys, and data directory.
* Delegate environment variable and password secret loading to the server module (`gcp-gce-server`) and its generic `app.env` loader. This capability now only materializes SSH host-key files and runs the container.
* Drop the inline `-e` app-env flags from the container start command; environment now comes from `--env-file /run/app-secrets/app.env`.
