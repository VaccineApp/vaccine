noinst_LIBRARIES = libbayes-glib-1.0.a

pkgincludedir = $(includedir)/bayes-glib-1.0
pkginclude_HEADERS = \
	bayes-classifier.h \
	bayes-glib.h \
	bayes-guess.h \
	bayes-storage-memory.h \
	bayes-storage.h \
	bayes-tokenizer.h \
	bayes-version.h

libbayes_glib_1_0_a_SOURCES = \
	$(pkginclude_HEADERS) \
	bayes-classifier.c \
	bayes-guess.c \
	bayes-guess-private.h \
	bayes-storage-memory-private.h \
	bayes-storage-memory.c \
	bayes-storage.c \
	bayes-tokenizer.c

libbayes_glib_1_0_a_CFLAGS = $(BAYES_GLIB_CFLAGS)
libbayes_glib_1_0_a_LIBADD = $(BAYES_GLIB_LIBS) -lm

-include $(INTROSPECTION_MAKEFILE)
INTROSPECTION_GIRS =
INTROSPECTION_SCANNER_ARGS = --add-include-path=$(srcdir) --warn-all
INTROSPECTION_COMPILER_ARGS = --includedir=$(srcdir)

introspection_sources_0 = \
	bayes-classifier.c \
	bayes-guess.c \
	bayes-storage-memory.c \
	bayes-storage.c \
	bayes-tokenizer.c

introspection_sources = $(introspection_sources_0)
introspection_sources += $(introspection_sources_0:.c=.h)
introspection_sources += \
	bayes-guess-private.h \
	bayes-storage-memory-private.h

Bayes-1.0.gir: $(INTROSPECTION_SCANNER) $(lib_LTLIBRARIES)
Bayes_1_0_gir_PACKAGES = gobject-2.0 gio-2.0 glib-2.0 json-glib-1.0
Bayes_1_0_gir_INCLUDES = GObject-2.0 GLib-2.0 Gio-2.0 Json-1.0
Bayes_1_0_gir_CFLAGS = -I$(builddir) -I$(srcdir)
Bayes_1_0_gir_SCANNERFLAGS = --c-include="bayes-glib.h"
Bayes_1_0_gir_LIBS = $(lib_LTLIBRARIES)
Bayes_1_0_gir_FILES = $(introspection_sources)
Bayes_1_0_gir_NAMESPACE = Bayes
Bayes_1_0_gir_EXPORT_PACKAGES = bayes-glib-1.0
INTROSPECTION_GIRS += Bayes-1.0.gir

girdir = $(datadir)/gir-1.0
gir_DATA = $(INTROSPECTION_GIRS)

typelibdir = $(libdir)/girepository-1.0
typelib_DATA = $(INTROSPECTION_GIRS:.gir=.typelib)

CLEANFILES = $(gir_DATA) $(typelib_DATA)

-include $(VAPIGEN_MAKEFILE)

bayes-glib-1.0.vapi: Bayes-1.0.gir

VAPIGEN_VAPIS = bayes-glib-1.0.vapi

bayes_glib_1_0_vapi_DEPS = \
	gio-2.0 \
	json-glib-1.0

bayes_glib_1_0_vapi_METADATADIRS = $(srcdir)
bayes_glib_1_0_vapi_FILES = Bayes-1.0.gir

bayes-glib-1.0.deps: Makefile
	$(AM_V_GEN) echo $(bayes_glib_1_0_vapi_DEPS) | tr ' ' '\n' > $@

vapidir = $(datadir)/vapi
vapi_DATA = $(VAPIGEN_VAPIS) $(VAPIGEN_VAPIS:.vapi=.deps)

EXTRA_DIST = bayes-glib-1.0.deps

DISTCLEANFILES = $(vapi_DATA)

#-include $(top_srcdir)/git.mk
