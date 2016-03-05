data_desktopdir = $(datadir)/applications
data_desktop_DATA = org.vaccine.app.desktop

data_appdatadir = $(datadir)/appdata
data_appdata_DATA = org.vaccine.app.appdata.xml

data_servicedir = $(datadir)/dbus-1/services
data_service_DATA = org.vaccine.app.service

gsettings_SCHEMAS = org.vaccine.app.gschema.xml
@GSETTINGS_RULES@

gschemas.compiled: Makefile $(gsettings_SCHEMAS:.xml=.valid)
	$(AM_V_GEN) $(GLIB_COMPILE_SCHEMAS) --targetdir=$(builddir) $(builddir)

$(data_service_DATA): Makefile
	$(AM_V_GEN)  (echo '[D-BUS Service]'; \
		       echo 'Name=org.vaccine.app'; \
		       echo 'Exec=${bindir}/vaccine --gapplication-service') > $@.tmp && \
		       mv $@.tmp $@

CLEANFILES = \
	gschemas.compiled \
	org.vaccine.app.gschema.valid

all-local: gschemas.compiled
