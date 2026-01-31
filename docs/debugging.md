# Debugging Guide

## Display Issues

### No Display (White Screen)
- Check connections (SPI, Power).
- Verify `dmesg | grep ili9486` shows driver loaded.
- Check `config.txt` for `dtoverlay=ili9486-drm-overlay`.

### Driver Not Loading
- Run `lsmod | grep ili9486`.
- Check DKMS status: `sudo dkms status`.

## Touch Issues

### No Touch Response
- Check `libinput list-devices`.
- Verify `dtoverlay=xpt2046-overlay` is loaded.
- Check interrupt pin (IRQ).

### Inverted Axis
- Edit `/boot/firmware/overlays/xpt2046-overlay.dts` (or override via config.txt).
- Use `swapxy=1` in `config.txt` overlay parameter (if supported/implemented).
- Update udev rules `LIBINPUT_CALIBRATION_MATRIX`.

## Logs
```bash
dmesg | grep -iE "drm|spi|ili9486|xpt2046"
cat /var/log/Xorg.0.log
```
