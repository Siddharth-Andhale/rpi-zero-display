# Helper makefile to install source to /usr/src
PROJECT_NAME := panel-ili9486
VERSION := 1.0
DKMS_DEST := /usr/src/$(PROJECT_NAME)-$(VERSION)

install-src:
	install -d $(DKMS_DEST)
	install -m 644 ../kernel/panel-ili9486.c $(DKMS_DEST)/
	install -m 644 ../kernel/Makefile $(DKMS_DEST)/
	install -m 644 dkms.conf $(DKMS_DEST)/
