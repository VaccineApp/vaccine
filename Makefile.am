SUBDIRS = contrib data
bin_PROGRAMS = vaccine

vaccine_SOURCES = \
	src/App.vala \
	src/Catalog.vala \
	src/FourChan.vala \
	src/Thread.vala \
	src/PostReplies.vala \
	src/ErrorDialog.vala \
	src/media/MediaPreview.vala \
	src/media/ImagePreview.vala \
	src/media/VideoPreview.vala \
	src/media/MediaStore.vala \
	src/model/Board.vala \
	src/model/Page.vala \
	src/model/Post.vala \
	src/util/PostTextBuffer.vala \
	src/util/PostTransformer.vala \
	src/util/Stripper.vala \
	src/view/CatalogItem.vala \
	src/view/CatalogWidget.vala \
	src/view/CoverImage.vala \
	src/view/MainWindow.vala \
	src/view/MediaView.vala \
	src/view/NotebookPage.vala \
	src/view/PanelView.vala \
	src/view/PostListRow.vala \
	src/view/PreferencesView.vala \
	src/view/ThreadPane.vala \
	src/view/widgets/VideoPreviewWidget.vala \
	resources.c

vaccine_VALAFLAGS = \
    --vapidir=$(top_srcdir)/contrib \
    --pkg gtk+-3.0 \
    --pkg json-glib-1.0 \
    --pkg libsoup-2.4 \
    --pkg gee-0.8 \
    --pkg gstreamer-1.0 \
    --pkg gstreamer-base-1.0 \
    --pkg gtksourceview-3.0 \
    --pkg bayes-glib-1.0 \
    --target-glib=2.38 \
    --gresources=$(top_srcdir)/data/vaccine.gresource.xml \
    --enable-experimental \
    --enable-checking \
    --thread

vaccine_CFLAGS = \
	-Wno-incompatible-pointer-types \
	$(GTK3_CFLAGS) \
	$(JSON_GLIB_CFLAGS) \
	$(SOUP_CFLAGS) \
	$(GEE_CFLAGS) \
	$(GSTREAMER_CFLAGS) \
	$(GSTREAMER_BASE_CFLAGS) \
	$(GTKSOURCEVIEW_CFLAGS) \
	-I$(top_srcdir)/contrib/bayes-glib/src \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function

vaccine_LDADD = \
	$(GTK3_LIBS) \
	$(JSON_GLIB_LIBS) \
	$(SOUP_LIBS) \
	$(GEE_LIBS) \
	$(GSTREAMER_LIBS) \
	$(GSTREAMER_BASE_LIBS) \
	$(GTKSOURCEVIEW_LIBS) \
	$(top_builddir)/contrib/libbayes-glib-1.0.a \
	-lm

# GResources
vaccine_resources = $(shell glib-compile-resources --sourcedir=data --generate-dependencies data/vaccine.gresource.xml)
resources.c: data/vaccine.gresource.xml $(vaccine_resources)
	glib-compile-resources --sourcedir=data --generate-source --target $@ $<

# GSettings
gsettings_SCHEMAS = data/org.vaccine.app.gschema.xml
@GSETTINGS_RULES@

run: vaccine
	G_MESSAGES_DEBUG=all \
	GOBJECT_DEBUG=instance-count \
	gdb -ex run vaccine

EXTRA_DIST = $(gsettings_SCHEMAS)

CLEANFILES = *.h *.c *.o *.stamp \
	vaccine $(vaccine_SOURCES:.vala=.c) \
	$(vaccine_SOURCES:.vala=.lo)

GITIGNOREFILES = \
	aclocal.m4 \
	compile \
	depcomp \
	install-sh \
	missing \
	config.guess \
	config.sub \
	ltmain.sh

-include $(top_srcdir)/git.mk
