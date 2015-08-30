SUBDIRS = src schemas

run: all
		G_MESSAGES_DEBUG=all \
		GOBJECT_DEBUG=instance-count \
		gdb -ex run src/vaccine
