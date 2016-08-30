.PHONY: help dist

ADDON_NAME=$(shell basename `pwd`)

help:
	cat Makefile

$(ADDON_NAME).zip: dist

dist:
	rm -f $(ADDON_NAME).zip
	cd `mktemp -d` && \
		mkdir $(ADDON_NAME); \
		cp -r $(CURDIR)/*.{toc,lua,xml} $(CURDIR)/Libs $(ADDON_NAME)/; \
		zip -r $(CURDIR)/$(ADDON_NAME).zip $(ADDON_NAME) -x "*.DS_Store" "_MACOSX"
	unzip -l $(ADDON_NAME).zip
