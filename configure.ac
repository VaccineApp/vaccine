AC_INIT([vaccine], [0.1])

AM_INIT_AUTOMAKE([foreign subdir-objects])
AM_SILENT_RULES([yes])

AC_PROG_CC
AM_PROG_VALAC

PKG_CHECK_MODULES([GTK3], [gtk+-3.0])
PKG_CHECK_MODULES([JSON_GLIB], [json-glib-1.0])
PKG_CHECK_MODULES([SOUP], [libsoup-2.4])
PKG_CHECK_MODULES([GEE], [gee-0.8])

AM_VALAFLAGS=" \
    --pkg gtk+-3.0 \
    --pkg json-glib-1.0 \
    --pkg libsoup-2.4 \
    --pkg gee-0.8 \
    --target-glib=2.38 \
    --gresources=\$(top_srcdir)/ui/resources.xml \
    --enable-experimental \
    --enable-checking \
    --thread"

AC_SUBST(AM_VALAFLAGS)

AC_CONFIG_FILES([
    Makefile
    src/Makefile
])

AC_OUTPUT

echo "
    ${PACKAGE_NAME} ${PACKAGE_VERSION}

    C compiler: ${CC}
    Vala compiler: ${VALAC}
"

