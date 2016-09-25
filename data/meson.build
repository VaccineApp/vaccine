gnome = import('gnome')

gnome.compile_schemas()

resfile = files('vaccine.gresource.xml')
res = gnome.compile_resources('my', resfile, source_dir: '.')
res_args = ['--gresources', resfile]

install_subdir('hicolor', install_dir: 'share/icons')
install_data('vaccine.desktop', install_dir: 'share/applications')
install_data('org.vaccine.app.appdata.xml', install_dir: 'share/appdata')
install_data('org.vaccine.app.gschema.xml', install_dir: 'share/glib-2.0/schemas')
