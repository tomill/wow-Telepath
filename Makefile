.PHONY: help dist

ADDON_NAME=$(shell basename `pwd`)

help:
	cat Makefile

dist:
	cd `mktemp -d` && \
		mkdir $(ADDON_NAME); \
		cp -r $(CURDIR)/*.{toc,lua,xml} $(CURDIR)/Libs $(ADDON_NAME)/; \
		zip -r $(CURDIR)/Telepath.zip $(ADDON_NAME) -x "*.DS_Store" "_MACOSX"
