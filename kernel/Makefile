# Makefile for panel-ili9486

ifneq ($(KERNELRELEASE),)
# kbuild part of makefile
obj-m := panel-ili9486.o

else
# normal makefile
PWD := $(shell pwd)
KERNEL_VER ?= $(shell uname -r)
KDIR := /lib/modules/$(KERNEL_VER)/build

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

dkms:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
endif
