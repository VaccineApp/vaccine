gsettings_SCHEMAS = org.vaccine.app.gschema.xml
@GSETTINGS_RULES@

gschemas.compiled: $(gsettings_SCHEMAS:.xml=.valid)
	$(AM_V_GEN) $(GLIB_COMPILE_SCHEMAS) .

all-local: gschemas.compiled

EXTRA_DIST = $(gsettings_SCHEMAS)

CLEANFILES = gschemas.compiled
