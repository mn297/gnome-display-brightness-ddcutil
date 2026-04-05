Display Brightness Slider for Gnome Shell

![screenshot](screenshot.jpg)

- [Setup ddcutil](#setup-ddcutil)
- [Installation](#installation)
  - [Automatically from GNOME extensions](#automatically-from-gnome-extensions)
  - [Manually from the source code](#manually-from-the-source-code)
- [Troubleshoot](#troubleshoot)
  - [Screen hangs/locks on first startup](#screen-hangslocks-on-first-startup)
  - [Docking or Daisy chain](#docking-or-daisy-chain)
  - [Cannot detect display](#cannot-detect-display)
- [Credits](#credits)
    - [Thanks to the following people for contributing via pull requests:](#thanks-to-the-following-people-for-contributing-via-pull-requests)
    - [Thanks to the following extensions for the inspiration](#thanks-to-the-following-extensions-for-the-inspiration)
## Setup ddcutil

1. install `ddcutil`

2. Manually load kernel module `i2c-dev`

```sh

sudo modprobe i2c-dev

```

3. Verify that your monitor supports brightness control

```sh

ddcutil capabilities | grep "Feature: 10"

```

4. udev rule for giving group i2c RW permission on the `/dev/i2c` devices

ddcutil 2.0+
```sh

sudo cp /usr/share/ddcutil/data/60-ddcutil-i2c.rules /etc/udev/rules.d

```
**Note: Fedora 40+ and OpenSUSE Aeon users, you need to uncomment this line**
```
# KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
```

Prior ddcutil 1.4.0
```sh

sudo cp /usr/share/ddcutil/data/45-ddcutil-i2c.rules /etc/udev/rules.d

```

Read more: [https://www.ddcutil.com/i2c_permissions/](https://www.ddcutil.com/i2c_permissions/)


5. Create i2c group and add yourself

```sh

sudo groupadd --system i2c

sudo usermod $USER -aG i2c

```

6. load `i2c-dev` automatically

```sh

sudo touch /etc/modules-load.d/i2c.conf

sudo sh -c 'echo "i2c-dev" >> /etc/modules-load.d/i2c.conf'

```

7. Reboot for changes to take effect

```sh

sudo reboot

```

This tool uses ddcutil as backend, so first make sure that your user can use use following shell commands without root or sudo.

`ddcutil getvcp 10` to check the brightness of a monitor and

`ddcutil setvcp 10 100` to set the brightness to 100

It automatically supports multiple displays detected by

`ddcutil detect`


## Installation

### Automatically from GNOME extensions
You can find this extension [here](https://extensions.gnome.org/extension/2645/brightness-control-using-ddcutil/)

### Manually from the source code
Clone this repo and in the repo's root directory run these shell commands

```sh
make build
make install
```

## Troubleshoot

### Screen hangs/locks on first startup
In my hardware for some reason when `ddcutil detect` is ran for the first time after a cold boot and then, when it checks for i2c busno=1, whole system locks for couple of seconds.
As a workaround I changed this extension to read cached info from a file, when it exists.

```sh
ddcutil --brief detect > $XDG_CACHE_HOME/ddcutil_detect
```
### Docking or Daisy chain

If you using a dock and are having issues:

Read more about issues with dock [ddcutil.com FAQ](https://www.ddcutil.com/faq/#docking)

Also some docks use daisy chaining behind the scenes.

If you are daisy chaining the monitors i.e. instead of connecting each monitor to the GPU/Laptop directly, you are connecting monitor to another monitor. Then try to tweak the extension settings `Advanced settings` > `ddcutil Sleep Multipler ms`. Daisy chain doesn't allow running parallel instance of ddcutil.


### Cannot detect display

If you have issues detecting the display and stuck in "Initializing", check if disabling display state check from extension settings `Advanced settings` > `Disable Display State Check` works.

If you find your monitor listed on [rockowitz/ddcutil repo wiki](https://github.com/rockowitz/ddcutil/wiki/Notes-on-Specific-Monitors), check what is recommended for your monitor.

## Credits

This extension wouldn't exist without [rockowitz/ddcutil](https://github.com/rockowitz/ddcutil)

This extension is developed and maintained by [@daitj](https://github.com/daitj)

#### Thanks to the following people for contributing via pull requests:
- @oscfdezdz for adding new settings UI, keyboard shortcuts and ability to set icon location
- @maniacx for porting the extension to GNOME 45
#### Thanks to the following extensions for the inspiration
- [Night Theme Switcher](https://extensions.gnome.org/extension/2236/night-theme-switcher/) for keyboard shortcut UI.

## How GNOME Shell Extensions Work

GNOME Shell extensions are JavaScript add-ons that run inside the GNOME Shell process (`gnome-shell`). They can modify the panel, system menu, add keyboard shortcuts, and more.

### Key concepts

- **metadata.json** — Every extension has this file. It declares the extension UUID, name, supported shell versions, and GSettings schema ID. The UUID (e.g. `display-brightness-ddcutil@themightydeity.github.com`) is used as the folder name.
- **extension.js** — The main entry point. GNOME Shell calls `enable()` when the extension is activated and `disable()` when it is deactivated or the screen locks.
- **prefs.js** — The preferences entry point. Opened by `gnome-extensions prefs <uuid>` or the GNOME Extensions app. Runs in a separate process (not inside gnome-shell).
- **GSettings schema** — Extensions store settings using GSettings. The XML schema is compiled to a binary `gschemas.compiled` file. The schema lives in `schemas/` inside the extension folder.
- **stylesheet.css** — Optional CSS for styling UI elements added by the extension.

### Installation folders

| Location | Scope |
|----------|-------|
| `~/.local/share/gnome-shell/extensions/<uuid>/` | Per-user install (from `gnome-extensions install` or Extensions website) |
| `/usr/share/gnome-shell/extensions/<uuid>/` | System-wide install (from distro packages like apt/dnf) |

The per-user folder takes precedence over the system folder if both exist.

### Do you need to reboot?

No full reboot is needed. After installing or updating:

- **Wayland** (default on most distros): Log out and log back in, or run `gnome-extensions enable <uuid>` from a terminal.
- **X11**: Press `Alt+F2`, type `r`, press Enter to restart the shell in-place.

You can also enable/disable extensions without restarting using:
```sh
gnome-extensions enable display-brightness-ddcutil@themightydeity.github.com
gnome-extensions disable display-brightness-ddcutil@themightydeity.github.com
```

### What modules / dependencies does this extension install?

The extension itself installs no system packages or libraries. It only copies JavaScript, UI, CSS, and schema files into the extensions folder. However, it **requires** these to already be on your system:

- `ddcutil` — the CLI tool that talks to monitors over I2C/DDC
- `i2c-dev` kernel module — loaded via `modprobe i2c-dev`
- User membership in the `i2c` group — for permission to access `/dev/i2c-*` devices

### Useful commands

```sh
# List all installed extensions
gnome-extensions list

# Show info about this extension
gnome-extensions info display-brightness-ddcutil@themightydeity.github.com

# Open the preferences window
gnome-extensions prefs display-brightness-ddcutil@themightydeity.github.com

# View live extension logs
journalctl -f -o cat /usr/bin/gnome-shell
```

## Development: Running from Source

```sh
# Clone the repo
git clone https://github.com/daitj/gnome-display-brightness-ddcutil.git
cd gnome-display-brightness-ddcutil

# Build (compiles schemas and packs the extension zip)
make build

# Install into ~/.local/share/gnome-shell/extensions/
make install

# Enable the extension
gnome-extensions enable display-brightness-ddcutil@themightydeity.github.com
```

After making changes, rebuild and reinstall:
```sh
make build && make install
```
Then restart GNOME Shell (log out/in on Wayland, or `Alt+F2` → `r` on X11).

## Uninstalling

### Uninstall per-user install

```sh
gnome-extensions uninstall display-brightness-ddcutil@themightydeity.github.com
```

This removes `~/.local/share/gnome-shell/extensions/display-brightness-ddcutil@themightydeity.github.com/`.

Or manually:
```sh
rm -rf ~/.local/share/gnome-shell/extensions/display-brightness-ddcutil@themightydeity.github.com
```

### Uninstall system-wide install (from distro package)

First, find how it was installed:

```sh
# Check if it exists as a system extension
ls /usr/share/gnome-shell/extensions/ | grep ddcutil

# Find which package owns the files (Debian/Ubuntu)
dpkg -S /usr/share/gnome-shell/extensions/display-brightness-ddcutil@themightydeity.github.com

# Find which package owns the files (Fedora/RHEL)
rpm -qf /usr/share/gnome-shell/extensions/display-brightness-ddcutil@themightydeity.github.com
```

Then remove the package:
```sh
# Debian/Ubuntu
sudo apt remove gnome-shell-extension-ddcutil   # package name may vary

# Fedora
sudo dnf remove gnome-shell-extension-ddcutil   # package name may vary
```

If it was manually copied (not from a package), remove the folder directly:
```sh
sudo rm -rf /usr/share/gnome-shell/extensions/display-brightness-ddcutil@themightydeity.github.com
```

### Reset extension settings

To clear all saved settings back to defaults:
```sh
dconf reset -f /org/gnome/shell/extensions/display-brightness-ddcutil/
```

## Per-Monitor Keyboard Shortcuts

In addition to the global "Increase/Decrease Brightness" shortcuts (which affect all monitors), you can assign separate shortcuts for each individual monitor.

### How it works

- Open the extension preferences: `gnome-extensions prefs display-brightness-ddcutil@themightydeity.github.com`
- Scroll to **Per-Monitor Keyboard Shortcuts**
- Assign increase/decrease shortcuts for Monitor 1 through Monitor 4
- Leave a shortcut empty to disable it

### Monitor numbering

Monitor numbers (1-4) correspond to the order monitors appear in the output of:

```sh
ddcutil detect --brief
```

If you have the internal slider enabled, the internal display is always listed first. External DDC monitors follow in the order `ddcutil` discovers them (typically by I2C bus number).

To check which monitor is which number, run `ddcutil detect --brief` and note the order. The first display listed = Monitor 1, second = Monitor 2, etc.

## Delay / flickering analysis

### Write collector uses 1ms `setInterval` ticks

`ddcWriteInQueue` creates a `setInterval` with a **1ms** interval that counts down from `ddcutil-queue-ms` (default 130). This means ~130 timer callbacks fire every millisecond on the GNOME Shell main loop just to implement a delay before writing to DDC. Each tick decrements a counter by 1 and checks if it reached zero.

This is expensive in a single-threaded UI event loop — every 1ms tick forces GNOME Shell to wake up, run the callback, and return to the event loop. A single `setTimeout` of 130ms would achieve the same result with one callback instead of 130.

### `onSettingsChange` fires on every GSettings key change

`connectSettingsSignals` connects a `changed` handler to the **entire** GSettings object (not a specific key). Any GSettings key change — including per-monitor shortcut key assignments from the preferences dialog — triggers `onSettingsChange`, which calls:

1. `removeKeyboardShortcuts()` — unbinds all shortcuts
2. `addKeyboardShortcuts()` — rebinds all shortcuts
3. `reloadMenuWidgets()` — destroys and recreates all slider widgets

This full rebuild of the UI on every settings change causes visible flickering. The workaround is to filter out irrelevant key changes (e.g. per-monitor shortcut keys) in the `changed` handler so they don't trigger a full reload.

### DDC/I2C is inherently slow

Each `ddcutil setvcp` call involves I2C bus communication with a mandatory sleep (controlled by `--sleep-multiplier`). The minimum practical write interval is ~130ms (45ms DDC delay + 85ms post-write wait). Rapid slider changes queue up writes that can't be dispatched faster than this, creating a perceived lag between the slider position and the actual monitor brightness catching up.
