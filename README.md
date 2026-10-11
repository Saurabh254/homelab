# Homelab Infrastructure

Personal homelab configurations, self-hosted services, and infrastructure automation.

> [!NOTE]
> This repository is maintained for personal use and homelab experimentation.

---

## Services & Modules

### 🔐 [Vaultwarden Local (`vaultwarden-local/`)](vaultwarden-local/)
A self-hosted, resilient [Vaultwarden](https://github.com/dani-garcia/vaultwarden) deployment built around physical decoupling:
- **Decoupled Persistent Storage**: Vaultwarden database and keys reside on a dedicated removable USB drive rather than the server's boot disk.
- **Docker Compose**: Containerized service definition with minimal external attack surface.
- **Systemd Watchdog**: Automated health-checking daemon (`vaultwarden-watchdog.service` & `.timer`) that restarts containers or alerts on drive dismount.
- **Automation Scripts**: Shell installation script (`scripts/install.sh`) for streamlined host setup.

---

## Directory Structure

```
homelab/
└── vaultwarden-local/
    ├── docker/             # Docker Compose configurations
    ├── docs/               # Architecture diagrams and step-by-step guides
    ├── scripts/            # Host setup and deployment scripts
    └── systemd/            # Watchdog service and timer units
```

---

## Getting Started

See each service directory's documentation for detailed deployment instructions, for example:
- [Vaultwarden Setup Guide](vaultwarden-local/docs/installation.md)
- [Vaultwarden Architecture Overview](vaultwarden-local/docs/architecture.md)

---

## License

Personal & Educational use.
