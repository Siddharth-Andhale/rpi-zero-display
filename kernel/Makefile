# Makefile for panel-ili9486

obj-m := panel-ili9486.o

PWD := $(shell pwd)

# If KERNEL_VER is not set (manual build), detect it.
# If DKMS sets KERNEL_VER, use that.
# (Note: standard DKMS sets KERNELRELEASE, but we force KERNEL_VER in dkms.conf)
KERNEL_VER ?= $(shell uname -r)

KDIR := /lib/modules/$(KERNEL_VER)/build

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

# Dedicated target for DKMS
dkms:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
