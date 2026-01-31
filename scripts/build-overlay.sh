#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$0")
OVERLAY_DIR="$SCRIPT_DIR/../overlays"

echo "Building overlays..."
make -C "$OVERLAY_DIR"

if [ $? -eq 0 ]; then
    echo "Overlays built successfully."
else
    echo "Failed to build overlays."
    exit 1
fi
