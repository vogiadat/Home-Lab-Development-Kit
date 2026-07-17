# Ubuntu VM Validation Checklist

Use this inside the Ubuntu Server VM.

## Base System

- [ ] Ubuntu Server is installed.
- [ ] Static IP is `192.168.100.10/24`.
- [ ] Gateway is `192.168.100.1`.
- [ ] DNS works.
- [ ] SSH service is running.
- [ ] Windows host can SSH into Ubuntu.

## Updates

- [ ] `sudo apt update` succeeds.
- [ ] `sudo apt upgrade -y` succeeds.
- [ ] Reboot completes.
- [ ] SSH still works after reboot.

## Docker

- [ ] `./scripts/Ubuntu/install-docker.sh` succeeds.
- [ ] User logs out and back in.
- [ ] `docker version` succeeds.
- [ ] `docker compose version` succeeds.
- [ ] `docker run --rm hello-world` succeeds.

## Home Lab Directory

- [ ] `./scripts/Ubuntu/bootstrap-homelab-dir.sh` succeeds.
- [ ] `/opt/homelab` exists.
- [ ] `/opt/homelab/data/postgres` exists.
- [ ] `/opt/homelab/data/redis` exists.
- [ ] `/opt/homelab/data/nginx` exists.

## Compose Stack

- [ ] `compose.yaml` is copied to `/opt/homelab`.
- [ ] `.env` is created from `env.example`.
- [ ] Default password is changed.
- [ ] `docker compose up -d` succeeds.
- [ ] `docker compose ps` shows services running.
- [ ] `docker system df` output is reviewed.
