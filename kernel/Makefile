# Makefile for panel-ili9486

obj-m := panel-ili9486.o

PWD := $(shell pwd)
KERNEL_VER ?= $(shell uname -r)

all:
	$(MAKE) -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

# Dedicated target for DKMS
dkms:
	$(MAKE) -C /lib/modules/$(KERNEL_VER)/build M=$(PWD) modules

clean:
	$(MAKE) -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
