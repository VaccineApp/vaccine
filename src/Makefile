DEPS = gtk+-3.0 json-glib-1.0 libsoup-2.4 gio-unix-2.0

SRCS = Bloop.vala Board.vala Page.vala

all: $(SRCS)
	valac                       \
		--pkg gtk+-3.0      \
		--pkg json-glib-1.0 \
		--pkg libsoup-2.4   \
		--pkg gio-unix-2.0  \
		$(SRCS)

.PHONY: clean
clean:
	-rm $(BIN)
