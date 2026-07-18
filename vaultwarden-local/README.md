# Vaultwarden Homelab

Self-hosted Vaultwarden running in Docker with:

- Docker Compose
- Tailscale HTTPS
- USB-backed persistent storage
- Automatic mount monitoring
- Automatic start/stop
- Systemd watchdog

## Repository Layout

```
docker/
systemd/
scripts/
docs/
```

## Install

```bash
cp .env.example .env
vim .env
docker compose up -d
./scripts/install.sh
```

## Features

- Automatic recovery after reboot
- Automatic stop if storage disappears
- Automatic restart when storage comes back
- Tailnet-only access
