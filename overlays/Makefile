DTC := dtc

all: ili9486-drm.dtbo xpt2046.dtbo

ili9486-drm.dtbo: ili9486-drm-overlay.dts
	$(DTC) -@ -I dts -O dtb -o $@ $<

xpt2046.dtbo: xpt2046-overlay.dts
	$(DTC) -@ -I dts -O dtb -o $@ $<

clean:
	rm -f *.dtbo
