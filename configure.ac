AC_INIT([vaccine], [0.0.1])

AC_CONFIG_AUX_DIR([build-aux])

AM_INIT_AUTOMAKE([foreign subdir-objects no-dist-gzip dist-xz])
AM_SILENT_RULES([yes])

AX_CHECK_ENABLE_DEBUG([yes])

AC_PROG_CC
AM_PROG_VALAC

GLIB_GSETTINGS

PKG_CHECK_MODULES([GLIB], [glib-2.0 >= 2.44])
PKG_CHECK_MODULES([GTK3], [gtk+-3.0])
PKG_CHECK_MODULES([JSON_GLIB], [json-glib-1.0])
PKG_CHECK_MODULES([SOUP], [libsoup-2.4])
PKG_CHECK_MODULES([GEE], [gee-0.8])
PKG_CHECK_MODULES([GSTREAMER], [gstreamer-1.0])
PKG_CHECK_MODULES([GSTREAMER_BASE], [gstreamer-base-1.0])
PKG_CHECK_MODULES([GSTREAMER_PLUGINS_BAD], [gstreamer-plugins-bad-1.0]) # just check for this
PKG_CHECK_MODULES([GTKSOURCEVIEW], [gtksourceview-3.0])

AS_IF([test "x$enable_debug" != "xno"], [AM_VALAFLAGS="$AM_VALAFLAGS -D DEBUG"], [])

AC_CONFIG_FILES([Makefile
		   data/Makefile])
AC_CONFIG_SUBDIRS([bayes-glib])

AC_OUTPUT

echo "
    ${PACKAGE_NAME} ${PACKAGE_VERSION}

    C compiler: ${CC}
    Vala compiler: ${VALAC}
"
