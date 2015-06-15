AM_CFLAGS = $(VACCINE_CFLAGS) -Wno-incompatible-pointer-types -g

bin_PROGRAMS = vaccine
noinst_LTLIBRARIES = libvaccine.la

vaccine_sources = \
	Vaccine.vala \
	Thread.vala \
	model/Board.vala \
	model/Catalog.vala \
	model/Post.vala \
	ThreadWatcher.vala \
	FourChan.vala \
	view/ThreadWidget.vala \
	view/PostListRow.vala \
	view/MainWindow.vala

ui_dir = $(top_srcdir)/ui
resources.c: $(ui_dir)/resources.xml
	glib-compile-resources \
		--sourcedir=$(ui_dir) \
		--generate-source \
		--target $@ $(ui_dir)/resources.xml

libvaccine_la_SOURCES = $(vaccine_sources)
libvaccine_la_VALAFLAGS = --library vaccine -H vaccine.h $(VACCINE_VALA_FLAGS)
libvaccine_la_LIBADD = $(VACCINE_LIBS)

vaccine_SOURCES = main.vala resources.c
vaccine_LDADD = libvaccine.la $(VACCINE_LIBS)
vaccine_VALAFLAGS = vaccine.vapi $(VACCINE_VALA_FLAGS)

CLEANFILES = *.h *.c *.o *.stamp *.stamp-t resources.c libvaccine.la vaccine $(vaccine_sources:.vala=.c)
