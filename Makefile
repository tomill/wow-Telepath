.PHONY: help dist

ADDON_NAME=$(shell basename `pwd`)

help:
	cat Makefile

dist:
	rm -rf $(ADDON_NAME)
	mkdir $(ADDON_NAME)
	cp -r $(ADDON_NAME).toc *.lua Libs $(ADDON_NAME)/
	zip -r $(ADDON_NAME).zip $(ADDON_NAME) -x \*.DS_Store \_MACOSX
	rm -rf $(ADDON_NAME)
