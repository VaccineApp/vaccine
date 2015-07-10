bin_PROGRAMS = vaccine

vaccine_SOURCES = \
	App.vala \
	Thread.vala \
	FourChan.vala \
	Catalog.vala \
	PostFormatter.vala \
	Stripper.vala \
	Util.vala \
	model/Board.vala \
	model/Page.vala \
	model/Post.vala \
	view/ThreadPane.vala \
	view/PostListRow.vala \
	view/MainWindow.vala \
	view/CatalogWidget.vala \
	view/CatalogItem.vala \
	view/Tab.vala \
	resources.c

vaccine_resources = $(shell glib-compile-resources --sourcedir=$(top_srcdir)/ui --generate-dependencies $(top_srcdir)/ui/resources.xml)
resources.c: $(top_srcdir)/ui/resources.xml $(vaccine_resources)
	glib-compile-resources --sourcedir=$(top_srcdir)/ui --generate-source --target $@ $<

vaccine_CFLAGS = \
	-g \
	-Wno-incompatible-pointer-types \
	$(GTK3_CFLAGS) \
	$(JSON_GLIB_CFLAGS) \
	$(SOUP_CFLAGS) \
	$(GEE_CFLAGS)

vaccine_LDADD = \
	$(GTK3_LIBS) \
	$(JSON_GLIB_LIBS) \
	$(SOUP_LIBS) \
	$(GEE_LIBS)

CLEANFILES = *.h *.c *.o *.stamp resources.c vaccine $(vaccine_SOURCES:.vala=.c) $(vaccine_SOURCES:.vala=.lo)
