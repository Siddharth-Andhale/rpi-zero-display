#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR="$SCRIPT_DIR/.."
KERNEL_VER=$(uname -r)

CONFIG_TXT="/boot/firmware/config.txt"
if [ ! -f "$CONFIG_TXT" ]; then
    CONFIG_TXT="/boot/config.txt"
fi

echo "============================================="
echo " Installing ILI9486 DRM Driver & Overlays"
echo " Kernel: $KERNEL_VER"
echo " Config: $CONFIG_TXT"
echo "============================================="

# 1. Check Prerequisites
echo "[1/5] Checking prerequisites..."
if ! dpkg -s raspberrypi-kernel-headers >/dev/null 2>&1 && ! dpkg -s linux-headers-$KERNEL_VER >/dev/null 2>&1; then
    echo "Error: Kernel headers not found. Please run: sudo apt install raspberrypi-kernel-headers"
    exit 1
fi
if ! command -v dkms >/dev/null; then
    echo "Error: dkms not found. Please run: sudo apt install dkms"
    exit 1
fi
if ! command -v dtc >/dev/null; then
    echo "Error: device-tree-compiler not found. Please run: sudo apt install device-tree-compiler"
    exit 1
fi

# 2. Build and Install Overlays
echo "[2/5] Building and installing overlays..."
$ROOT_DIR/scripts/build-overlay.sh

OVERLAYS_DIR="/boot/firmware/overlays"
if [ ! -d "$OVERLAYS_DIR" ]; then
    OVERLAYS_DIR="/boot/overlays"
fi

cp $ROOT_DIR/overlays/*.dtbo "$OVERLAYS_DIR/"
echo "Overlays installed to $OVERLAYS_DIR"

# 3. DKMS Install
echo "[3/5] Installing Kernel Module via DKMS..."
# Check if already installed
if dkms status | grep -q "panel-ili9486"; then
    echo "Module already in DKMS, removing first..."
    dkms remove -m panel-ili9486 -v 1.0 --all
fi

# Copy source to /usr/src
SRC_DEST="/usr/src/panel-ili9486-1.0"
mkdir -p "$SRC_DEST"
cp "$ROOT_DIR/kernel/panel-ili9486.c" "$SRC_DEST/"
cp "$ROOT_DIR/kernel/Makefile" "$SRC_DEST/"
cp "$ROOT_DIR/dkms/dkms.conf" "$SRC_DEST/"

dkms add -m panel-ili9486 -v 1.0
dkms build -m panel-ili9486 -v 1.0
dkms install -m panel-ili9486 -v 1.0

# 4. Update config.txt
echo "[4/5] Updating config.txt..."

# Backup
cp "$CONFIG_TXT" "$CONFIG_TXT.bak"
echo "Backup created at $CONFIG_TXT.bak"

# Helper to add line if missing
add_config() {
    grep -qF "$1" "$CONFIG_TXT" || echo "$1" >> "$CONFIG_TXT"
}

# Ensure SPI is on
if grep -q "dtparam=spi=on" "$CONFIG_TXT"; then
    : # already on
else
    # Check if commented out
    if grep -q "#dtparam=spi=on" "$CONFIG_TXT"; then
        sed -i 's/#dtparam=spi=on/dtparam=spi=on/' "$CONFIG_TXT"
    else
        add_config "dtparam=spi=on"
    fi
fi

# Add overlays
# Remove old entries to prevent duplicates/conflicts (simple cleanup)
sed -i '/dtoverlay=ili9486-drm/d' "$CONFIG_TXT"
sed -i '/dtoverlay=xpt2046/d' "$CONFIG_TXT"

echo "# ILI9486 DRM Display" >> "$CONFIG_TXT"
echo "dtoverlay=ili9486-drm-overlay,speed=32000000,rotate=90" >> "$CONFIG_TXT"
echo "dtoverlay=xpt2046-overlay" >> "$CONFIG_TXT"

# 5. Userspace Config (udev)
echo "[5/5] Installing userspace configurations..."
cp "$ROOT_DIR/userspace/udev/99-xpt2046-calibration.rules" /etc/udev/rules.d/ 2>/dev/null || true

echo "============================================="
echo " Installation Complete!"
echo " Please REBOOT to enable the display."
echo "============================================="
