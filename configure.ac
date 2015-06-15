AC_INIT([vaccine], [0.1])

AM_INIT_AUTOMAKE([foreign subdir-objects])
AM_SILENT_RULES([yes])

LT_INIT
AC_PROG_CC
AM_PROG_VALAC

PKG_CHECK_MODULES([VACCINE], [
                    gtk+-3.0
                    json-glib-1.0
                    libsoup-2.4
                    gee-0.8
                 ])

VACCINE_VALA_FLAGS=" \
    --pkg gtk+-3.0 \
    --pkg json-glib-1.0 \
    --pkg libsoup-2.4 \
    --pkg gee-0.8 \
    --target-glib=2.38 \
    --gresources=\$(top_srcdir)/ui/resources.xml"

AC_SUBST(VACCINE_CFLAGS)
AC_SUBST(VACCINE_LIBS)
AC_SUBST(VACCINE_VALA_FLAGS)

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

