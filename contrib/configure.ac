AC_PREREQ([2.69])


dnl ***********************************************************************
dnl Define Versioning Information
dnl ***********************************************************************
m4_define([major_version],[0])
m4_define([minor_version],[2])
m4_define([micro_version],[2])
m4_define([package_version],[major_version.minor_version.micro_version])
m4_define([bug_report_url],[https://github.com/chergert/bayes-glib/issues])
m4_define([interface_age],[0])


dnl ***********************************************************************
dnl Initialize autoconf
dnl ***********************************************************************
AC_INIT([bayes-glib],[package_version],[bug_report_url])
AC_CONFIG_HEADERS([bayes-glib/config.h])
AC_CONFIG_SRCDIR([bayes-glib/data/bayes-glib-1.0.pc.in])
AC_CONFIG_MACRO_DIR([bayes-glib/m4])
AC_CONFIG_AUX_DIR([bayes-glib/build-aux])
AC_SUBST(ACLOCAL_AMFLAGS, "-I bayes-glib/m4")
AC_CANONICAL_HOST


dnl ***********************************************************************
dnl Make version information available to autoconf files
dnl ***********************************************************************
MAJOR_VERSION=major_version
MINOR_VERSION=minor_version
MICRO_VERSION=micro_version
AC_SUBST(MAJOR_VERSION)
AC_SUBST(MINOR_VERSION)
AC_SUBST(MICRO_VERSION)


dnl ***********************************************************************
dnl Initialize automake
dnl ***********************************************************************
AM_SILENT_RULES([yes])
AM_INIT_AUTOMAKE([1.11 foreign subdir-objects tar-ustar no-dist-gzip dist-xz])
AM_MAINTAINER_MODE([enable])


dnl ***********************************************************************
dnl Check for required programs
dnl ***********************************************************************
AC_PROG_CC
AM_PROG_VALAC
AC_PROG_INSTALL
AC_PATH_PROG([GLIB_GENMARSHAL],[glib-genmarshal])
AC_PATH_PROG([GLIB_MKENUMS],[glib-mkenums])
AC_PATH_PROG([GLIB_COMPILE_RESOURCES],[glib-compile-resources])
PKG_PROG_PKG_CONFIG([0.22])
GLIB_GSETTINGS
GOBJECT_INTROSPECTION_CHECK([1.42.0])
VAPIGEN_CHECK


dnl ***********************************************************************
dnl Check for required packages
dnl ***********************************************************************
PKG_CHECK_MODULES(BAYES_GLIB, [gio-2.0 >= 2.46.0
                               json-glib-1.0])


dnl ***********************************************************************
dnl Initialize Libtool
dnl ***********************************************************************
LT_PREREQ([2.2])
LT_INIT([static])


dnl ***********************************************************************
dnl Process .in Files
dnl ***********************************************************************
AC_CONFIG_FILES([
	bayes-glib/Makefile
	bayes-glib/src/bayes-version.h
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
