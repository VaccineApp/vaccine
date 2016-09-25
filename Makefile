debug:
	if [ ! -d build ]; then \
		mkdir build; \
		meson build; \
	fi
	ninja -C build
	gdb -ex run build/vaccine
