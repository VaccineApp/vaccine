project('vaccine', 'vala', 'c')

conf = configuration_data()
conf.set('package', 'Vaccine')
conf.set('version', '0.0.2')

deps = [
    dependency('glib-2.0', version: '>=2.44'),
    dependency('gobject-2.0'),
    dependency('gtk+-3.0'),
    dependency('json-glib-1.0'),
    dependency('libsoup-2.4'),
    dependency('gee-0.8'),
    dependency('gstreamer-1.0'),
    dependency('gstreamer-base-1.0'),
    dependency('gtksourceview-3.0'),
    meson.get_compiler('c').find_library('m', required: false)
]

# just check for it
dependency('gstreamer-plugins-bad-1.0')

subdir('contrib')
subdir('data')
subdir('src')

executable('vaccine',
            [src, res, bayes_glib],
            dependencies: deps,
            vala_args: [res_args, bayes_glib_args],
            include_directories: [config_inc, bayes_glib_inc],
            c_args: '-w',
            install: true)
