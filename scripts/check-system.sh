#!/bin/bash

KERNEL_VER=$(uname -r)
echo "System Check:"
echo "Kernel: $KERNEL_VER"

echo -n "Kernel Headers: "
if dpkg -s raspberrypi-kernel-headers >/dev/null 2>&1 || dpkg -s linux-headers-$KERNEL_VER >/dev/null 2>&1; then
    echo "INSTALLED"
else
    echo "MISSING (Run: sudo apt install raspberrypi-kernel-headers)"
fi

echo -n "DKMS: "
if command -v dkms >/dev/null; then
    echo "INSTALLED"
else
    echo "MISSING (Run: sudo apt install dkms)"
fi

echo -n "Device Tree Compiler: "
if command -v dtc >/dev/null; then
    echo "INSTALLED"
else
    echo "MISSING (Run: sudo apt install device-tree-compiler)"
fi
