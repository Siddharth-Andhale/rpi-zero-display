#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi

CONFIG_TXT="/boot/firmware/config.txt"
if [ ! -f "$CONFIG_TXT" ]; then
    CONFIG_TXT="/boot/config.txt"
fi

echo "============================================="
echo " Uninstalling ILI9486 DRM Driver"
echo "============================================="

# 1. DKMS Remove
echo "[1/3] Removing DKMS module..."
if dkms status | grep -q "panel-ili9486"; then
    dkms remove -m panel-ili9486 -v 1.0 --all
    rm -rf /usr/src/panel-ili9486-1.0
else
    echo "Module not found in DKMS."
fi

# 2. Remove Overlays
echo "[2/3] Removing overlays..."
OVERLAYS_DIR="/boot/firmware/overlays"
[ -d "$OVERLAYS_DIR" ] || OVERLAYS_DIR="/boot/overlays"

rm -f "$OVERLAYS_DIR/ili9486-drm-overlay.dtbo"
rm -f "$OVERLAYS_DIR/xpt2046-overlay.dtbo"

# 3. Restore config.txt
echo "[3/3] Cleaning config.txt..."
sed -i '/# ILI9486 DRM Display/d' "$CONFIG_TXT"
sed -i '/dtoverlay=ili9486-drm-overlay/d' "$CONFIG_TXT"
sed -i '/dtoverlay=xpt2046-overlay/d' "$CONFIG_TXT"

echo "Uninstallation Complete. Please REBOOT."
