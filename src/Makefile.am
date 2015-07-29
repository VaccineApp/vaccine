bin_PROGRAMS = vaccine

vaccine_SOURCES = \
	App.vala \
	Catalog.vala \
	FourChan.vala \
	PostFormatter.vala \
	Thread.vala \
	PostReplies.vala \
	model/Board.vala \
	model/Page.vala \
	model/Post.vala \
	util/Stripper.vala \
	view/AboutDialog.vala \
	view/CatalogItem.vala \
	view/CatalogWidget.vala \
	view/MainWindow.vala \
	view/PanelView.vala \
	view/PostListRow.vala \
	view/Tab.vala \
	view/ThreadPane.vala \
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
