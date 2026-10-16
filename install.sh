#!/usr/bin/env bash
# Install zpl-autoprint as a systemd user service.
set -euo pipefail
cd "$(dirname "$0")"

install -Dm755 zpl-autoprint "$HOME/.local/bin/zpl-autoprint"
install -Dm644 zpl-autoprint.service "$HOME/.config/systemd/user/zpl-autoprint.service"

systemctl --user daemon-reload
systemctl --user enable zpl-autoprint.service
systemctl --user restart zpl-autoprint.service
systemctl --user --no-pager status zpl-autoprint.service
