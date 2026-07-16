#!/usr/bin/env bash
set -euo pipefail

HOMELAB_DIR="${HOMELAB_DIR:-/opt/homelab}"

echo "Creating ${HOMELAB_DIR} layout..."

sudo mkdir -p "${HOMELAB_DIR}/data/postgres"
sudo mkdir -p "${HOMELAB_DIR}/data/redis"
sudo mkdir -p "${HOMELAB_DIR}/data/nginx"
sudo mkdir -p "${HOMELAB_DIR}/scripts"
sudo chown -R "$USER:$USER" "${HOMELAB_DIR}"

echo "Home lab directory ready: ${HOMELAB_DIR}"
