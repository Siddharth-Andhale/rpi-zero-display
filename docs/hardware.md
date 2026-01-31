# Hardware Connections

## ILI9486 SPI Display (3.5 inch RPi LCD)

| LCD Pin | RPi Pin | Function |
|---------|---------|----------|
| 1 (3.3V)| 1 (3.3V)| Power |
| 2 (5V)  | 2 (5V)  | Power |
| 18 (GND)| 6 (GND) | Ground |
| 19 (MOSI)| 19 (SPI0 MOSI) | SPI Data |
| 21 (MISO)| 21 (SPI0 MISO) | SPI Data (Touch) |
| 22 (TP_IRQ)| 11 (GPIO 17)| Touch Interrupt |
| 23 (SCLK)| 23 (SPI0 SCLK) | SPI Clock |
| 24 (T_CS)| 26 (SPI0 CE1) | Touch Chip Select |
| 26 (CS)  | 24 (SPI0 CE0) | LCD Chip Select |
| 18 (RS/DC)| 18 (GPIO 24) | Data/Command |
| 22 (RST) | 22 (GPIO 25) | Reset |

*Note: Pinout is based on standard Waveshare 3.5" (B) / (C) type displays. Verify your specific module.*
