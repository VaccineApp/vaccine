BIN = Vaccine
SRC = $(wildcard src/*.vala)
XML = ui/resources.xml

DEPS = gtk+-3.0 json-glib-1.0 libsoup-2.4 gee-0.8
VALACFLAGS = -g --target-glib=2.38 --gresources=$(XML)

$(BIN): clean $(SRC) resources.c
	valac $(VALACFLAGS) -o $(BIN) $(foreach pkg, $(DEPS), --pkg $(pkg)) $(SRC) resources.c

resources.c: $(XML) $(shell glib-compile-resources --generate-dependencies --sourcedir=ui $(XML))
	glib-compile-resources $(XML) --target=$@ --generate-source --sourcedir=ui

.PHONY: clean
clean:
	-rm $(BIN) resources.c src/*.c
