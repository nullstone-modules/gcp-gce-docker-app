# gcp-gce-docker-app

Nullstone capability that runs a Docker container on a `gcp-gce-server` instance
(Container-Optimized OS) as a systemd service.

## How it works

`gcp-gce-server` owns all environment variables and secrets. Per the server
contract, it writes `app.env` (and any secret files) to a known tmpfs path
(`/run/app-secrets` by default). This capability only:

1. Re-runs the server loader on every service start (tmpfs clears on reboot).
2. Starts the container as `<container_name>.service` with
   `--env-file /run/app-secrets/app.env` (plain `docker run` + systemd).

The container always gets two bind mounts for free: the secrets mount
(read-only) and the server's data dir (read-write). Use `volumes` for anything
else.

## Requirements

- A Docker-capable image (Container-Optimized OS recommended).

Secret access (IAM) is handled by `gcp-gce-server`; this capability requires no
`secretAccessor` grants.

## Inputs

### `image_url` (required)

The container image to run, passed to `docker run` as-is. Include the tag or
digest you want pinned — there is no implicit `:latest` handling, and the
instance pulls whatever this resolves to at service start.

```yaml
image_url: "ghcr.io/drakkan/sftpgo:v2.6"
```

### `container_name` (optional, default `app`)

Names three things at once: the Docker container, the systemd unit
(`<container_name>.service`), and the on-disk script directory
(`/app/<container_name>/docker-app-up.sh`). Pick something an admin will
recognize, because it is what they type:

```bash
systemctl status sftpgo
journalctl -u sftpgo
```

Must start with a letter or digit and contain only letters, digits, `_`, `.`,
and `-` (validated). Set this when you run more than one docker-app capability
on the same server — the default `app` will collide.

### `ports` (optional, default `[]`)

Ports published from the container to the VM. Each entry becomes one
`-p host_ip:host_port:container_port` flag.

| Field | Required | Default | Meaning |
| --- | --- | --- | --- |
| `container_port` | yes | — | The port the app listens on inside the container. |
| `host_port` | yes | — | The port on the VM to publish it as. |
| `host_ip` | no | `0.0.0.0` | Host interface to bind. |

Leave `host_ip` alone to accept traffic from outside the VM (firewall rules on
the server module still govern what actually reaches it). Set it to `127.0.0.1`
to keep a port reachable only from the VM itself — useful for an admin or
metrics port you front with something else on the same host.

```yaml
ports:
- container_port: 2022
  host_port: 22
- container_port: 8080
  host_port: 8080
  host_ip: "127.0.0.1"
```

### `volumes` (optional, default `[]`)

Extra bind mounts from the VM host into the container, on top of the secrets
mount and data dir that are always mounted. Each entry becomes one
`-v src:target[:ro]` flag.

| Field | Required | Default | Meaning |
| --- | --- | --- | --- |
| `src` | yes | — | Path on the VM host. |
| `target` | yes | — | Path inside the container. |
| `read_only` | no | `true` | Mount read-only; set `false` when the app must write. |

The main use is remapping a file the server dropped into the secrets mount onto
the path the image actually expects — SSH host keys are the common case, since
the container needs them at a fixed location and must not modify them:

```yaml
volumes:
- src: "/run/app-secrets/id_ed25519"
  target: "/etc/sftpgo/id_ed25519"
  read_only: true
- src: "/run/app-secrets/id_rsa"
  target: "/etc/sftpgo/id_rsa"
  read_only: true
```

Note that `src` must already exist on the host — this capability does not create
host paths. Write-heavy state belongs under the server's data dir rather than in
an ad-hoc mount, so it survives container replacement.

### `app_metadata` (reserved)

Injected automatically by Nullstone from the app module. This capability reads
`data_dir` and `secrets_mount` from it to build the two default bind mounts, so
those two paths are coordinated with `gcp-gce-server` and are not
user-configurable.

## Outputs

`cloud_init_stanzas` — the `write_files` and `runcmd` entries this capability
contributes to the parent `gcp-gce-server` cloud-init. Consumed by the server
module; nothing to wire up by hand.

## Example

```yaml
capabilities:
  app:
    module: nullstone/gcp-gce-docker-app
    vars:
      image_url: "ghcr.io/drakkan/sftpgo:v2.6"
      container_name: "sftpgo"
      ports:
      - container_port: 2022
        host_port: 22
      volumes:
      - src: "/run/app-secrets/id_ed25519"
        target: "/etc/sftpgo/id_ed25519"
        read_only: true
```
