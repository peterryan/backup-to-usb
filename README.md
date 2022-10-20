# backup_to_usb.sh
Bash script to copy files from your home directory to a backup device such as
USB flash media. It uses `rsync` to do the copy and `zenity` for the GUI.

## Installation
To install, copy files to these locations:

 * `/usr/local/bin/backup_to_usb.sh`
 * `/usr/local/bin/backup_to_usb_rsync.awk`
 * `/usr/local/share/icons/backup_to_usb.svg`
 * `/usr/local/share/applications/backup_to_usb.desktop`

You will likely want to create a `~/.rsync-usbflash-filter` file to include or
exclude files/dirs from your backup.

## Usage
Once the `.desktop` file has been installed, you should be able to launch this
as you would any other program.

You can also start this from the command line.

```
Usage: backup_to_usb.sh [f filename] [-n] [-h]

    -f    set rsync per-dir filter filename (default .rsync-usbflash-filter)
    -n    dry-run
    -h    display this help text and exit
```

## License

The icon included with this project (backup_to_usb.svg) is licensed:
[![License: CC0-1.0](https://img.shields.io/badge/License-CC0_1.0-lightgrey.svg)](http://creativecommons.org/publicdomain/zero/1.0/)

Everything except the icon (backup_to_usb.svg) is licensed:
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

