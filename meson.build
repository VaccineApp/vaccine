project('vaccine', 'vala', 'c')

conf = configuration_data()
conf.set('package', 'Vaccine')
conf.set('version', '0.0.2')

gtksourceview = dependency('gtksourceview-3.0', required: false)
if not gtksourceview.found()
  gtksourceview = dependency('gtksourceview-4')
endif

deps = [
    dependency('glib-2.0', version: '>=2.44'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('json-glib-1.0'),
    dependency('libsoup-2.4'),
    dependency('gee-0.8'),
    dependency('gstreamer-1.0'),
    dependency('gstreamer-base-1.0'),
    gtksourceview,
    meson.get_compiler('c').find_library('m', required: false)
]

gtksink = run_command('gst-inspect-1.0', 'gtksink')
if gtksink.returncode() != 0
  error('you need gtksink')
endif

subdir('contrib')
subdir('data')
subdir('src')

executable('vaccine',
            [src, res, bayes_glib],
            dependencies: deps,
            vala_args: [res_args, bayes_glib_args, json_glib_local_args],
            include_directories: [config_inc, bayes_glib_inc],
            c_args: '-w',
            install: true)

meson.add_install_script('data/post-install.sh')
