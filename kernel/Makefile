# Makefile for panel-ili9486

# Default target for manual build
all:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

# Dedicated target for DKMS to avoid KERNELRELEASE confusion
dkms:
	make -C /lib/modules/$(KERNEL_VER)/build M=$(PWD) modules

clean:
	make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean

# Kbuild part: strictly for when invoked by kernel build system
ifneq ($(KERNELRELEASE),)
	obj-m += panel-ili9486.o
endif
