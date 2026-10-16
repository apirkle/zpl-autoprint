#!/usr/bin/env bash
# Remove the zpl-autoprint service and script. Pass --purge to also delete the config.
set -euo pipefail

systemctl --user disable --now zpl-autoprint.service 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/zpl-autoprint.service" "$HOME/.local/bin/zpl-autoprint"
systemctl --user daemon-reload

if [[ "${1:-}" == --purge ]]; then
    rm -rf "${XDG_CONFIG_HOME:-$HOME/.config}/zpl-autoprint"
    echo "removed zpl-autoprint and its config"
else
    echo "removed zpl-autoprint (config kept; use --purge to delete it)"
fi
