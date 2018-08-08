ARTIFACT=$(shell basename `pwd`)

dist: $(ARTIFACT).zip

.PHONY: $(ARTIFACT).zip
$(ARTIFACT).zip:
	@-rm -f $@
	cd `mktemp -d` && \
		mkdir $(ARTIFACT); \
		cp -r $(CURDIR)/*.{toc,lua,xml} $(CURDIR)/Libs $(ARTIFACT)/; \
		zip -q -r $(CURDIR)/$(ARTIFACT).zip $(ARTIFACT) -x "*.DS_Store" "_MACOSX"
	unzip -l $@
