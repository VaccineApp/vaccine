#!/bin/bash

# Packaging tools define DESTDIR and this isn't needed for them
if [[ $DESTDIR == "" ]]; then
    glib-compile-schemas $MESON_INSTALL_PREFIX/share/glib-2.0/schemas
    gtk-update-icon-cache -qt $MESON_INSTALL_PREFIX/share/icons/hicolor
    update-desktop-database $MESON_INSTALL_PREFIX/share/applications
fi
