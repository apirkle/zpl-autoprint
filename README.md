# zpl-autoprint

Prints any `.zpl` file that lands in `~/Downloads` to the Zebra GK420t, as raw ZPL.
Made for Pirate Ship labels: download a label and it prints.

## Install

```
./install.sh
```

Installs the script to `~/.local/bin` and enables a systemd user service that starts at login.

## Use

- Download a `.zpl` file into `~/Downloads`. It prints and a desktop notification shows.
- Only files that appear while the service is running are printed. Existing files are left alone.
- To reprint a label: `lp -d Zebra_GK420t -o raw <file>.zpl`

## Logs and control

```
journalctl --user -u zpl-autoprint -f
systemctl --user stop zpl-autoprint      # pause auto-printing
systemctl --user start zpl-autoprint
```

## Config

Set these with `systemctl --user edit zpl-autoprint` (`[Service]` `Environment=...`):

| Variable        | Default        |
|-----------------|----------------|
| `ZPL_WATCH_DIR` | `~/Downloads`  |
| `ZPL_PRINTER`   | `Zebra_GK420t` |
| `ZPL_SETTLE`    | `1` (seconds)  |
