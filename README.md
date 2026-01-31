# Native SPI ILI9486 + XPT2046 Support for Raspberry Pi OS

This repository provides a **modern, DRM/KMS-based** solution for running ILI9486 SPI displays and XPT2046 touchscreens on Raspberry Pi OS (Bookworm/Trixie).

## Features
- **Pure DRM/KMS Driver**: No legacy framebuffer hacks (`fbcp`, `fbtft`).
- **DKMS Integration**: Automatically rebuilds on kernel updates.
- **Wayland Compatible**: Works out-of-the-box with `labwc`, `wayfire`, `weston`.
- **Easy Installation**: Automated install script.

## Requirements
- Raspberry Pi Zero 2 W, 3, 4, or 5.
- Raspberry Pi OS (64-bit recommended).
- Internet connection (for installing headers/dkms).

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/rpi-ili9486-drm.git
   cd rpi-ili9486-drm
   ```

2. Run the installer:
   ```bash
   sudo ./scripts/install.sh
   ```

3. Reboot:
   ```bash
   sudo reboot
   ```

## Configuration

### Rotation
Edit `/boot/firmware/config.txt`:
```ini
dtoverlay=ili9486-drm-overlay,rotate=90
```
Values: 0, 90, 180, 270.

### Touch Calibration
If axes are inverted, verify `userspace/udev/99-xpt2046-calibration.rules` or adjust overlay parameters.

## Troubleshooting
See [docs/debugging.md](docs/debugging.md).
