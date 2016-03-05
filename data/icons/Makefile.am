SUBDIRS = hicolor

icondir = $(datadir)/icons

nobase_icon_DATA = \
	hicolor/512x512/apps/vaccine.png \
	hicolor/256x256/apps/vaccine.png \
	hicolor/128x128/apps/vaccine.png \
	hicolor/64x64/apps/vaccine.png \
	hicolor/32x32/apps/vaccine.png \
	hicolor/24x24/apps/vaccine.png

EXTRA_DIST = $(nobase_icon_DATA)

gtk_update_icon_cache = gtk-update-icon-cache -f -t $(datadir)/icons/hicolor

install-data-hook: update-icon-cache
uninstall-hook: update-icon-cache
update-icon-cache:
	@-if test -z "$(DESTDIR)"; then \
		echo "Updating GTK icon cache."; \
		$(gtk_update_icon_cache); \
	else \
		echo "*** Icon cache not updated. After (un)install, run this:"; \
		echo "***    $(gtk_update_icon_cache)"; \
	fi
