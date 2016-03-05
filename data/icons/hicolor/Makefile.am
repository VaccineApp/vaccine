libicons_resources = $(shell glib-compile-resources \
	--sourcedir=$(top_srcdir)/data/icons/hicolor \
	--generate-dependencies $(top_srcdir)/data/icons/hicolor/icons.gresource.xml)

icons-resources.c: icons.gresource.xml $(libicons_resources) Makefile
	glib-compile-resources --sourcedir=$(top_srcdir)/data/icons/hicolor --generate-source --target $@ $<

all-local: icons-resources.c
