DEPS = gtk+-3.0 json-glib-1.0 libsoup-2.4 gio-unix-2.0
CFLAGS = `pkg-config --cflags $(DEPS)` -std=gnu11 -g -Wall -Wextra
LDLIBS = `pkg-config --libs $(DEPS)`

BIN = bloop
OBJECTS = Board.o Page.o

$(BIN): $(OBJECTS)

Board.c: Board.vala
	valac -H $*.h -C $<

Page.c: Page.vala
	valac -H $*.h -C $<

.PHONY: clean
clean:
	-rm $(BIN) $(OBJECTS)
