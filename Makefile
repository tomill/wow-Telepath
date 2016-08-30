.PHONY: help dist

ADDON_NAME=$(shell basename `pwd`)

help:
	cat Makefile

dist:
	rm -f $(ADDON_NAME).zip
	zip -r $(ADDON_NAME).zip . -i $(ADDON_NAME).toc "*.lua" "Libs/*"
