#!/bin/sh -e

if ! test -f contrib/bayes-glib/README.md; then
    git submodule update --init
fi

autoreconf -if
