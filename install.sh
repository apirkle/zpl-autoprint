#!/usr/bin/env bash
# Install zpl-autoprint as a systemd user service.
#
#   ./install.sh                  use the CUPS default printer
#   ./install.sh --printer NAME   use a specific CUPS queue
#
# An existing config file is never overwritten.
set -euo pipefail
cd "$(dirname "$0")"

printer=""
while (($#)); do
    case "$1" in
        -p|--printer) printer="${2:?--printer needs a CUPS queue name}"; shift 2 ;;
        *) echo "usage: $0 [--printer NAME]" >&2; exit 2 ;;
    esac
done

for cmd in inotifywait lp lpstat systemctl; do
    command -v "$cmd" >/dev/null || { echo "missing dependency: $cmd" >&2; exit 1; }
done

config="${XDG_CONFIG_HOME:-$HOME/.config}/zpl-autoprint/config"

install -Dm755 zpl-autoprint "$HOME/.local/bin/zpl-autoprint"
install -Dm644 zpl-autoprint.service "$HOME/.config/systemd/user/zpl-autoprint.service"

if [[ ! -f "$config" ]]; then
    if [[ -z "$printer" ]]; then
        printer="$(lpstat -d 2>/dev/null | sed -n 's/^system default destination: //p')"
    fi
    install -Dm644 config.example "$config"
    sed -i "s|^PRINTER=.*|PRINTER=$printer|" "$config"
    echo "wrote $config (PRINTER=${printer:-<CUPS default>})"
elif [[ -n "$printer" ]]; then
    sed -i "s|^PRINTER=.*|PRINTER=$printer|" "$config"
    echo "updated $config (PRINTER=$printer)"
else
    echo "keeping existing $config"
fi

systemctl --user daemon-reload
systemctl --user enable zpl-autoprint.service
systemctl --user restart zpl-autoprint.service
systemctl --user --no-pager status zpl-autoprint.service
