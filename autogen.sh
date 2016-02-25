#!/bin/sh -e

srcdir=`dirname $0`
test -n "$srcdir" || srcdir=.

gtkdocize --srcdir "$srcdir/bayes-glib" || exit 1
(cd "$srcdir"; autoreconf -i)

if test -z "$NOCONFIGURE"; then
    "$srcdir"/configure "$@"
fi
