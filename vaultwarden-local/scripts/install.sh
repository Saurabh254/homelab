#!/usr/bin/env bash
set -euo pipefail

echo "Installing systemd units..."

sudo cp systemd/vaultwarden-watchdog.service /etc/systemd/system/
sudo cp systemd/vaultwarden-watchdog.timer /etc/systemd/system/
sudo cp systemd/vaultwarden-watchdog /usr/local/bin/

sudo chmod +x /usr/local/bin/vaultwarden-watchdog

sudo systemctl daemon-reload
sudo systemctl enable --now vaultwarden-watchdog.timer

echo "Done."
