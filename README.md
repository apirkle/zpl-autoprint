# zpl-autoprint

Print ZPL label files the moment they're saved.

`zpl-autoprint` is a small Linux user service that watches a directory (by default
`~/Downloads`) and sends each new `.zpl` file straight to your label printer as raw ZPL.
Download a shipping label from your browser and it comes out of the printer. No print
dialog, no extra steps.

Works with any ZPL-capable printer set up in CUPS: Zebra GK/GX/ZD/ZT series, and
compatible thermal label printers.

## Features

- Prints new `.zpl` files automatically, including ones your browser downloads
- Handles Firefox and Chrome downloads correctly (each label prints exactly once)
- Skips files that don't contain ZPL (`^XA`)
- Desktop notification for each label printed (or failed)
- Runs as a systemd user service: no root needed, starts at login
- One small bash script, few dependencies

## Requirements

- Linux with systemd
- CUPS, with your printer added as a queue (`lpstat -p` lists them)
- `inotify-tools`
- `notify-send` (optional, for notifications; usually provided by `libnotify`)

```
# Arch
sudo pacman -S cups inotify-tools libnotify
# Debian / Ubuntu
sudo apt install cups-client inotify-tools libnotify-bin
# Fedora
sudo dnf install cups-client inotify-tools libnotify
```

## Install

```
git clone https://github.com/apirkle/zpl-autoprint.git
cd zpl-autoprint
./install.sh                     # use your CUPS default printer
./install.sh --printer Zebra_GK420t   # or name a specific CUPS queue
```

This installs the script to `~/.local/bin/zpl-autoprint`, writes a config file to
`~/.config/zpl-autoprint/config` (if one doesn't exist), and enables and starts the
`zpl-autoprint` user service.

Rerun `./install.sh` after pulling updates. Your config is kept.

## Configuration

`~/.config/zpl-autoprint/config`:

```
PRINTER=Zebra_GK420t     # CUPS queue; blank = CUPS default printer
WATCH_DIR=~/Downloads    # directory to watch
SETTLE_SECONDS=1         # wait after a file lands before printing
NOTIFY=yes               # desktop notifications
```

Restart after editing: `systemctl --user restart zpl-autoprint`

Any setting can also be overridden with an environment variable prefixed with `ZPL_`
(e.g. `ZPL_PRINTER=other_queue`), which is handy for a one-off run:

```
ZPL_WATCH_DIR=~/labels zpl-autoprint
```

## Usage

```
journalctl --user -u zpl-autoprint -f       # watch the log
systemctl --user stop zpl-autoprint         # pause auto-printing
systemctl --user start zpl-autoprint        # resume
lp -d Zebra_GK420t -o raw label.zpl         # reprint a label by hand
```

Only files that appear while the service is running are printed. Files already in
the directory are left alone. Downloading the same label again creates a new file,
which prints again.

## Printer setup tips

- The CUPS queue can use any driver. Files are sent with `-o raw`, so the driver
  never touches them. A raw queue works too:
  `sudo lpadmin -p Zebra -E -v <usb-uri> -m raw` (find the URI with `sudo lpinfo -v`).
- Some Zebra printers (e.g. GK420t) ship in EPL mode. If ZPL files print as text or
  not at all, switch the printer to ZPL:
  ```
  printf '! U1 setvar "device.languages" "zpl"\r\n' | lp -d <queue> -o raw
  ```
- If labels skip or print off-position, recalibrate the printer for your label stock.
  On most desktop Zebras, hold the feed button until the light flashes once, then let go.

## Uninstall

```
./uninstall.sh           # remove the service, keep config
./uninstall.sh --purge   # also delete config
```

## License

MIT
