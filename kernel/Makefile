# Makefile for panel-ili9486

# If KERNELRELEASE is defined, we've been invoked from the
# kernel build system and can use its language.
ifneq ($(KERNELRELEASE),)
	obj-m += panel-ili9486.o

# Otherwise we were called directly from the command
# line; invoke the kernel build system.
else
	KERNEL_VER ?= $(shell uname -r)
	KDIR ?= /lib/modules/$(KERNEL_VER)/build
	PWD := $(shell pwd)

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
endif
