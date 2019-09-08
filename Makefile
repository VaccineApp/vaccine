debug:
	-meson build
	ninja -C build
	gdb -ex run build/vaccine
