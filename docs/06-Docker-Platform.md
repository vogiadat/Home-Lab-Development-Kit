# Chapter 06 - Docker Platform

## Goal

This chapter installs Docker Engine and Docker Compose on the Ubuntu Server VM.

Docker is the main application platform for v1.0. Instead of creating a separate VM for every small service, the lab runs lightweight services as containers inside `VM-UBUNTU`.

## Target Layout

Diagram source: [`../diagrams/docker-platform.mmd`](../diagrams/docker-platform.mmd)

![Docker platform layout](assets/images/docker-platform.svg)

```text
/opt/homelab
├── compose.yaml
├── .env
├── data/
│   ├── postgres/
│   ├── redis/
│   └── nginx/
└── scripts/
```

This layout keeps service definitions, environment values, and persistent data in one predictable location.

## Why Docker Runs Inside Ubuntu

The reference laptop has limited CPU and SSD capacity.

Running Docker inside the Ubuntu VM avoids unnecessary layers:

```text
Windows Host
  -> Hyper-V
    -> Ubuntu Server VM
      -> Docker Engine
        -> Containers
```

Avoid this for v1.0:

```text
Windows Host
  -> Hyper-V
    -> Ubuntu VM
    -> Separate Docker VM
```

One main Ubuntu VM is easier to back up, monitor, and troubleshoot.

## Install Docker Engine

The repository provides an Ubuntu-side installer:

```text
scripts/Ubuntu/install-docker.sh
```

Copy it into the Ubuntu VM or run the commands manually.

Manual install:

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Add your user to the Docker group:

```bash
sudo usermod -aG docker "$USER"
```

Log out and log back in before running Docker without `sudo`.

## Verify Installation

```bash
docker version
docker compose version
docker run --rm hello-world
```

Expected result:

- Docker client and server versions are shown.
- Docker Compose plugin version is shown.
- `hello-world` runs successfully.

## Create the Home Lab Service Directory

```bash
sudo mkdir -p /opt/homelab/data/{postgres,redis,nginx}
sudo mkdir -p /opt/homelab/scripts
sudo chown -R "$USER:$USER" /opt/homelab
cd /opt/homelab
```

The repository includes a baseline Compose template:

```text
templates/docker/compose.yaml
templates/docker/env.example
```

Copy them to `/opt/homelab`:

```bash
cp compose.yaml /opt/homelab/compose.yaml
cp env.example /opt/homelab/.env
```

Then edit `.env` before starting services.

## Baseline Compose Stack

The v1.0 baseline includes:

| Service | Purpose |
| --- | --- |
| Nginx | Local reverse proxy placeholder |
| PostgreSQL | Development database |
| Redis | Lightweight cache/queue dependency |

This is intentionally small. Add services only when they have a real purpose.

Start:

```bash
cd /opt/homelab
docker compose up -d
```

Check:

```bash
docker compose ps
docker compose logs --tail=100
```

Stop:

```bash
docker compose down
```

## Persistent Data

Persistent data should live under:

```text
/opt/homelab/data
```

Avoid storing important data only inside anonymous Docker volumes until your backup process is clear.

Recommended:

```yaml
volumes:
  - ./data/postgres:/var/lib/postgresql/data
```

This makes backups easier because the data path is visible and predictable.

## Update Workflow

Update packages:

```bash
sudo apt update
sudo apt upgrade -y
```

Update containers:

```bash
cd /opt/homelab
docker compose pull
docker compose up -d
docker image prune -f
```

Do not blindly run destructive cleanup commands such as `docker system prune -a --volumes` unless you understand what will be deleted.

## Resource Guardrails

| Resource | Guardrail |
| --- | --- |
| Container count | Keep low for v1.0 |
| PostgreSQL memory | Keep defaults unless needed |
| Logs | Rotate or limit noisy services |
| Images | Prune unused images periodically |
| Disk | Keep host SSD at least 20% free |

Docker can silently consume disk space through images, logs, and build cache. Check usage regularly:

```bash
docker system df
df -h
```

## Basic Firewall Posture

If UFW is enabled, expose only what you use:

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw status verbose
```

For internal-only services such as PostgreSQL and Redis, do not publish ports to all interfaces unless required. Prefer Docker internal networks.

## Verification Commands

```bash
docker ps
docker compose ps
docker system df
sudo systemctl status docker
ss -tulpn
```

From Windows host:

```powershell
ssh <ubuntu-user>@192.168.100.10
curl http://192.168.100.10
```

## Common Mistakes

| Mistake | Impact |
| --- | --- |
| Running too many containers | Memory pressure and slow VM response |
| Publishing database ports unnecessarily | Larger attack surface |
| Ignoring Docker logs | Disk fills unexpectedly |
| Using anonymous volumes for important data | Harder backup and restore |
| Running all commands as root | Messy permissions |
| Skipping `docker compose ps` after deploy | Problems go unnoticed |

## Verification Checklist

- [ ] Docker Engine is installed.
- [ ] Docker Compose plugin is installed.
- [ ] User can run Docker without `sudo`.
- [ ] `/opt/homelab` exists.
- [ ] Baseline Compose stack starts successfully.
- [ ] Persistent data path is clear.
- [ ] Disk usage has been checked.
- [ ] No unnecessary ports are exposed.

## Exit Criteria

Before moving to Tailscale:

- Docker is installed and verified.
- Baseline Compose stack runs.
- SSH access to Ubuntu still works.
- You understand which ports are exposed.
- Persistent data location is known.
