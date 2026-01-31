# PLAN_OF_ACTION
## Native SPI ILI9486 + XPT2046 Support for Raspberry Pi OS (Trixie, 64-bit)

---

## 1. Objective

Create a **self-contained, clean, and modern solution** to run a **3.5-inch SPI LCD (ILI9486) with XPT2046 touch** on **Raspberry Pi OS (Trixie, 64-bit)**.

The solution must:
- Work on latest kernels
- Be upgrade-safe
- Avoid deprecated framebuffer methods
- Align with modern Linux DRM/KMS architecture
- Be distributable as a Git repository

---

## 2. Non-Goals

This project explicitly does **NOT**:
- Use `LCD-show`, `fbcp`, or `fbtft`
- Depend on `/dev/fb0`
- Rely on `/etc/rc.local`
- Force HDMI mirroring
- Patch systems destructively
- Support legacy Bullseye-only stacks

---

## 3. Target Platform

| Component | Specification |
|---------|--------------|
| Board | Raspberry Pi Zero 2 W |
| OS | Raspberry Pi OS (Trixie, 64-bit) |
| Kernel | >= 6.6 (rpt-rpi) |
| Display | SPI ILI9486 (480x320) |
| Touch | SPI XPT2046 |
| Graphics | DRM/KMS |
| Input | libinput |
| Display Server | Wayland (preferred), X11 optional |

---

## 4. High-Level Architecture

Userspace (Wayland / X11)
        ↓
       DRM / KMS
        ↓
 panel-mipi-dbi (kernel)
        ↓
       SPI
        ↓
   ILI9486 LCD

Touch Path:
XPT2046 → Linux Input Subsystem → libinput

---

## 5. Repository Structure

```
rpi-ili9486-drm/
├── README.md
├── PLAN_OF_ACTION.md
├── kernel/
│   ├── panel-ili9486.c
│   ├── Kconfig
│   └── Makefile
├── overlays/
│   ├── ili9486-drm-overlay.dts
│   ├── xpt2046-overlay.dts
│   └── Makefile
├── dkms/
│   ├── dkms.conf
│   └── Makefile
├── userspace/
│   ├── udev/
│   │   └── 99-xpt2046-calibration.rules
│   └── weston/
│       └── weston.ini
├── scripts/
│   ├── install.sh
│   ├── uninstall.sh
│   ├── check-system.sh
│   └── build-overlay.sh
└── docs/
    ├── debugging.md
    └── hardware.md
```

---

## 6. Phase 1 — Display Driver Development

### 6.1 Strategy

- Use Linux kernel framework: `drivers/gpu/drm/tiny/panel-mipi-dbi.c`
- Implement an **ILI9486 panel descriptor**, not a full DRM driver
- Register as a DRM panel

### 6.2 Driver Responsibilities

- SPI initialization sequence
- Resolution setup (480x320)
- Pixel format (RGB565)
- Rotation handling
- Power-on reset handling
- DRM connector registration

### 6.3 Success Criteria

- `/dev/dri/card0` exists
- `modetest` lists active connector
- No legacy framebuffer usage

---

## 7. Phase 2 — Device Tree Overlays

### 7.1 LCD Overlay

Responsibilities:
- Enable SPI bus
- Bind ILI9486 panel
- Define GPIOs (DC, RESET, CS)
- Configure SPI frequency
- Apply default rotation

### 7.2 Touch Overlay

Responsibilities:
- Bind XPT2046 / ADS7846 driver
- Configure PENIRQ GPIO
- Define SPI frequency
- Axis mapping

### 7.3 Deployment

- Compile `.dts` → `.dtbo`
- Install into `/boot/firmware/overlays`
- Enable via `/boot/firmware/config.txt`

---

## 8. Phase 3 — Touch Input Stack

### 8.1 Kernel Space

- Use existing `ads7846` / `xpt2046` driver
- No kernel modifications required

### 8.2 Userspace

- Use `libinput`
- Provide optional udev calibration rules

Success Criteria:
- Touch device visible via `libinput list-devices`
- Correct touch coordinates

---

## 9. Phase 4 — DKMS Integration

### 9.1 Purpose

- Automatic rebuild on kernel upgrades
- Clean installation & removal

### 9.2 DKMS Responsibilities

- Build panel module against running kernel
- Auto-install after kernel update
- Support uninstall

---

## 10. Phase 5 — Installer Design

### 10.1 install.sh

Must:
1. Detect OS and kernel compatibility
2. Verify SPI enabled
3. Build & install DKMS module
4. Compile & install overlays
5. Safely modify `config.txt`
6. Prompt reboot

### 10.2 uninstall.sh

Must:
- Remove DKMS module
- Remove overlays
- Restore `config.txt`
- Leave system clean

---

## 11. Debugging & Validation

### Display

```
dmesg | grep drm
modetest
```

### Touch

```
libinput list-devices
libinput debug-events
```

### SPI

```
ls /dev/spidev*
dmesg | grep spi
```

---

## 12. Performance Targets

| Metric | Target |
|------|-------|
| FPS | ~30 |
| SPI Clock | 32 MHz |
| CPU Usage | < 15% |
| Memory | < 30 MB |

---

## 13. Documentation Requirements

README.md must include:
- Supported hardware
- Installation steps
- Troubleshooting guide
- Kernel compatibility table
- FAQ (why legacy drivers are avoided)

---

## 14. Future Extensions

- Upstream submission
- Support for ILI9488
- Runtime rotation control
- Multi-panel support
- Raspberry Pi 5 validation

---

## 15. Board & OS Compatibility Notes

### 15.1 Supported Raspberry Pi Boards

This plan of action is designed to work uniformly across **all modern Raspberry Pi boards**, including:

- Raspberry Pi Zero
- Raspberry Pi Zero 2 W
- Raspberry Pi 3 / 3B+
- Raspberry Pi 4
- Raspberry Pi 5

The solution is board-agnostic because it relies on:
- DRM/KMS graphics stack
- `panel-mipi-dbi` SPI display framework
- Standard Linux SPI + GPIO subsystems

### 15.2 Supported Operating Systems

The plan fully supports:

- Raspberry Pi OS **Trixie (64-bit)**
- Raspberry Pi OS **Bookworm (64-bit)**
- Raspberry Pi OS **Desktop (Wayland or X11)**

Both **Lite** and **Full Desktop** images are supported.

### 15.3 Kernel Requirement

- Minimum kernel version: **Linux 6.1**
- Recommended kernel: **Latest `rpt-rpi` kernel** shipped with Raspberry Pi OS

This requirement ensures:
- Stable DRM support for SPI panels
- Mature `panel-mipi-dbi` framework
- Reliable libinput touch handling

### 15.4 SPI Clock & Board Differences

Different Raspberry Pi boards support different maximum SPI clock speeds.
The solution must allow SPI speed to be overridden via Device Tree parameters.

| Board | Recommended SPI Clock |
|------|----------------------|
| Zero / Zero 2 W | 16–24 MHz |
| Pi 3 | 24–30 MHz |
| Pi 4 | ~32 MHz |
| Pi 5 | 32–40 MHz |

### 15.5 GPIO Flexibility

- Default GPIO assignments will be documented
- Device Tree overlays must allow GPIO overrides
- No hardcoded GPIO assumptions in kernel code

---

## 16. Definition of Done

The project is considered complete when:

- Display works on Raspberry Pi OS Trixie 64-bit
- Touch works correctly via libinput
- DRM/KMS pipeline is used exclusively
- No legacy framebuffer or HDMI mirroring hacks exist
- Kernel upgrades do not break functionality
- Installation and uninstallation are clean and reversible
- The repository works across **all Raspberry Pi models**

---

## 17. Final Note

This plan intentionally aligns with **modern Linux graphics architecture**.
It replaces legacy SPI framebuffer approaches with a maintainable, future-proof DRM solution that scales across boards, operating systems, and desktop environments.

This is not a workaround — it is the **correct long-term engin