# Changelog

## [Unreleased]

### Changed
* Place `docker-app-up.sh` under `/etc/apps/<container_name>/` and call `/etc/nullstone/load-app-secrets.sh`; keep the unit at `/etc/systemd/system/<container_name>.service` (COS-writable + executable layout).

