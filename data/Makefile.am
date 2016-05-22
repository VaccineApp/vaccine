# .desktop file
desktopdir = $(datadir)/applications
desktop_DATA = org.vaccine.app.desktop

# icons
icondir = $(datadir)/icons
nobase_icon_DATA = \
	hicolor/16x16/apps/vaccine.png \
	hicolor/24x24/apps/vaccine.png \
	hicolor/32x32/apps/vaccine.png \
	hicolor/48x48/apps/vaccine.png \
	hicolor/96x96/apps/vaccine.png \
	hicolor/256x256/apps/vaccine.png \
	hicolor/512x512/apps/vaccine.png \
	hicolor/scalable/apps/vaccine.svg

# appstream
@APPSTREAM_XML_RULES@
appstream_XML = org.vaccine.app.appdata.xml

-include $(top_srcdir)/git.mk
