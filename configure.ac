AC_PREREQ([2.69])


dnl ***********************************************************************
dnl Define Versioning Information
dnl ***********************************************************************
m4_define([major_version],[0])
m4_define([minor_version],[0])
m4_define([micro_version],[1])
m4_define([package_version],[major_version.minor_version.micro_version])
m4_define([bug_report_url],[https://github.com/VaccineApp/vaccine/issues])

AX_IS_RELEASE([micro-version])


dnl ***********************************************************************
dnl Initialize autoconf
dnl ***********************************************************************
AC_INIT([vaccine], [package_version], [bug_report_url])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([build-aux])
AC_SUBST([ACLOCAL_AMFLAGS], "-I m4")
AC_CANONICAL_HOST


dnl ***********************************************************************
dnl Make version information available to autoconf files
dnl ***********************************************************************
AC_SUBST([MAJOR_VERSION],major_version)
AC_SUBST([MINOR_VERSION],minor_version)
AC_SUBST([MICRO_VERSION],micro_version)


dnl ***********************************************************************
dnl Initialize automake
dnl ***********************************************************************
AM_SILENT_RULES([yes])
AM_INIT_AUTOMAKE([1.11 foreign subdir-objects tar-ustar no-dist-gzip dist-xz -Wno-portability])
AM_MAINTAINER_MODE([enable])


dnl ***********************************************************************
dnl Add extra debugging with --enable-debug and --enable-compile-warnings
dnl ***********************************************************************
AX_CHECK_ENABLE_DEBUG([no],[]
                      [G_DISABLE_ASSERT G_DISABLE_CHECKS G_DISABLE_CAST_CHECKS])
AS_IF([test "x$enable_debug" != "xno"], [AM_VALAFLAGS="$AM_VALAFLAGS -D DEBUG"], [])


dnl ***********************************************************************
dnl Internationalization
dnl ***********************************************************************
dnl GETTEXT_PACKAGE=AC_PACKAGE_TARNAME
dnl AC_SUBST([GETTEXT_PACKAGE])
dnl AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [GETTEXT package name])

dnl AM_GNU_GETTEXT_VERSION([0.19.6])
dnl AM_GNU_GETTEXT([external])


dnl ***********************************************************************
dnl Check for required programs
dnl ***********************************************************************
AC_PROG_CC
AC_PROG_INSTALL
AC_PATH_PROG([GLIB_COMPILE_RESOURCES],[glib-compile-resources])
PKG_PROG_PKG_CONFIG([0.22])
GLIB_GSETTINGS
APPSTREAM_XML
AM_PROG_VALAC

AX_COMPILER_FLAGS


dnl ***********************************************************************
dnl Check for required packages
dnl ***********************************************************************
PKG_CHECK_MODULES([GLIB], [glib-2.0 >= 2.44])
PKG_CHECK_MODULES([GTK3], [gtk+-3.0 >= 3.18])
PKG_CHECK_MODULES([JSON_GLIB], [json-glib-1.0])
PKG_CHECK_MODULES([SOUP], [libsoup-2.4])
PKG_CHECK_MODULES([GEE], [gee-0.8])
PKG_CHECK_MODULES([GSTREAMER], [gstreamer-1.0])
PKG_CHECK_MODULES([GSTREAMER_BASE], [gstreamer-base-1.0])
PKG_CHECK_MODULES([GSTREAMER_PLUGINS_BAD], [gstreamer-plugins-bad-1.0])
PKG_CHECK_MODULES([GTKSOURCEVIEW], [gtksourceview-3.0])


dnl bayes-glib
LT_PREREQ([2.2])
LT_INIT([static])

dnl po/Makefile.in
AC_CONFIG_FILES([
    Makefile
    contrib/Makefile
    data/Makefile
])


AC_OUTPUT

echo ""
echo " ${PACKAGE} - ${VERSION}"
echo ""
echo " Options"
echo ""
echo "  Prefix ............................... : ${prefix}"
echo "  Libdir ............................... : ${libdir}"
echo ""