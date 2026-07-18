# Vaultwarden Homelab

A self-hosted [Vaultwarden](https://github.com/dani-garcia/vaultwarden) deployment built around a single design principle: **the vault's data should be physically decoupled from the host machine.**

Rather than storing the database on the server's boot disk, all persistent Vaultwarden state lives on a dedicated, removable USB drive. The host contributes compute; the drive owns the data. This makes the deployment trivially portable, resilient to OS reinstalls, and easy to take offline entirely.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Why store data on removable storage?](#why-store-data-on-removable-storage)
- [Storage layout](#storage-layout)
- [Automatic storage monitoring](#automatic-storage-monitoring)
- [Data persistence](#data-persistence)
- [Security](#security)
- [Project structure](#project-structure)
- [Installation](#installation)
- [Disaster recovery](#disaster-recovery)
- [Design goals](#design-goals)

---

## Features

- Self-hosted Vaultwarden via Docker Compose
- Persistent storage isolated on a dedicated USB drive
- Automatic start/stop driven by device presence, via a systemd watchdog
- Remote access over Tailscale (HTTPS + MagicDNS) — no public exposure
- Argon2-hashed admin token
- Public registration disabled
- Infrastructure fully defined as code
- Documented recovery procedure requiring no data migration

---

## Architecture

```
                    Internet
                        │
                (no public ingress)
                        │
                        ▼
                ┌─────────────────┐
                │    Tailscale    │
                │ HTTPS + MagicDNS│
                └────────┬────────┘
                         │
                         ▼
              cachyos.tailxxxxx.ts.net
                         │
                 tailscale serve
                         │
                   localhost:8080
                         │
                 Docker Compose
                         │
                   Vaultwarden
                         │
                 /data (bind mount)
                         │
            /mnt/vaultdisk/vaultwarden
                         │
                Dedicated USB drive
```

The host never terminates public traffic directly. All external access is brokered through the Tailnet, and the application itself only ever binds to localhost.

---

## Why store data on removable storage?

Most self-hosted Vaultwarden setups keep the SQLite database on the same disk as the operating system. This deployment instead treats the host as disposable and the USB drive as the source of truth.

That separation buys a few properties that are hard to get otherwise:

| Property | Benefit |
|---|---|
| Physical isolation | Secrets never share a disk with the OS |
| Portability | Migrating servers means moving a drive, not a database |
| Offline capability | The vault can be unplugged and stored securely when not in use |
| Simplified backups | Backups are just a drive, not a snapshot pipeline |
| Fast hardware replacement | A dead host doesn't threaten the vault |
| OS reinstall safety | Wiping the host has zero effect on stored data |

The host filesystem contains only Docker configuration and infrastructure code — never vault contents, and nothing sensitive is committed to the repository.

---

## Storage layout

```
USB Drive
└── /mnt/vaultdisk
    ├── vaultwarden/
    │   ├── db.sqlite3
    │   ├── attachments/
    │   ├── rsa_key.pem
    │   ├── icon_cache/
    │   └── sends/
    ├── backups/
    └── exports/
```

The repository itself is intentionally minimal:

```
vaultwarden-local/
├── docker/
├── scripts/
├── systemd/
├── docs/
└── README.md
```

---

## Automatic storage monitoring

A lightweight systemd watchdog continuously verifies that `/mnt/vaultdisk` is mounted, and reacts accordingly.

**USB removed:**

```
USB removed → watchdog detects missing mount → docker compose stop → Vaultwarden stops safely
```

**USB reinserted:**

```
USB inserted → filesystem mounts → watchdog detects mount → docker compose start → Vaultwarden resumes
```

No manual intervention is required in either direction.

### Why this is cheap

The watchdog's steady-state cost is a single check, run every few seconds:

```bash
mountpoint -q /mnt/vaultdisk
```

This is effectively free — no Docker log polling, no filesystem scanning, no database access, and no unnecessary container churn. Vaultwarden runs only when its storage is actually present.

---

## Data persistence

Containers in this deployment are treated as fully disposable — the container itself holds no state worth preserving. Everything that matters lives under `/mnt/vaultdisk/vaultwarden`:

- SQLite database
- Attachments
- Encryption keys (`rsa_key.pem`)
- Organizations and collections
- User accounts

Deleting or recreating the container has no effect on the vault.

---

## Security

**Network**
Vaultwarden is not exposed to the public internet. Access is available exclusively via Tailscale (HTTPS + MagicDNS); the service is unreachable from outside the Tailnet.

**Authentication**
- Strong master password required
- Two-factor authentication supported
- Admin token hashed with Argon2
- Public registration disabled

**Physical security**
Because the database lives on removable media, it can be disconnected and stored offline, survives a full host reinstall untouched, and migrates to new hardware by reconnecting the drive and starting Docker — no export/import step needed.

---

## Project structure

```
docker/
    vaultwarden/
        compose.yaml

systemd/
    vaultwarden-watchdog
    vaultwarden-watchdog.service
    vaultwarden-watchdog.timer

scripts/
    install.sh

docs/
    architecture.md
    installation.md
```

---

## Installation

```bash
# Clone the repository
git clone <repository>
cd vaultwarden-local

# Copy and edit the environment template
cp .env.example .env
nvim .env

# Deploy
docker compose -f docker/vaultwarden/compose.yaml up -d

# Install the storage watchdog
./scripts/install.sh
```

---

## Disaster recovery

If the host operating system is lost entirely, recovery requires no data migration:

1. Install Linux.
2. Install Docker.
3. Install Tailscale.
4. Clone this repository.
5. Mount the USB drive at `/mnt/vaultdisk`.
6. Run:

   ```bash
   docker compose up -d
   ```

Vaultwarden resumes immediately against the existing database on the drive.

---

## Design goals

This project optimizes for:

- **Simplicity** — minimal moving parts, no unnecessary services
- **Reliability** — the vault survives host failure by construction
- **Physical data separation** — secrets never depend on the host disk
- **Fast recovery** — a full server rebuild takes minutes, not hours
- **Minimal resource usage** — the watchdog's overhead is negligible
- **Infrastructure as code** — the entire deployment is reproducible from this repository

The encrypted vault is designed to remain completely independent of whatever machine happens to be running it.

## License

Add a license (e.g., MIT, Apache-2.0) to clarify usage terms for anyone forking this repository.
