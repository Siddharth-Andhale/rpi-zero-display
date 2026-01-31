# Makefile for panel-ili9486

obj-m := panel-ili9486.o

KDIR ?= /lib/modules/$(KERNELRELEASE)/build
PWD  := $(shell pwd)

# Default kernel build
all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

# DKMS entry point for the installer
dkms:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
