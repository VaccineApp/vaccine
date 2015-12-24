#!/bin/sh -e

srcdir=`dirname $0`
test -n "$srcdir" || srcdir=.

(cd "$srcdir"; autoreconf -i)

if test -z "$NOCONFIGURE"; then
    "$srcdir"/configure "$@"
fi
