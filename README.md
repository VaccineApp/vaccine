Vaccine
=======

![Catalog](res/vaccine-catalog.png)

![Media View](res/vaccine-mediaview.png)

![Panel View](res/vaccine-panelview.png)

This is an imageboard browser for Linux that is written in Vala and uses GTK.
Please contribute and report bugs.

# Dependencies
| Package name             | Version  |
|--------------------------|----------|
| glib2                    | >= 2.44  |
| vala                     |          |
| gtk3                     | >=3.18   |
| libsoup                  | >=2.4    |
| libgee                   | >=0.18   |
| gstreamer                | >=1.6    |
| gstreamer-plugins-bad    | >=1.6    |
| json-glib                | >=1.0    |
| gtksourceview3           | >=3.16   |

# Build Dependencies
| Package          |
|------------------|
| meson            |
| appstream-glib   |
| vala             |

Try it
---
```Bash
$ git clone --recursive https://github.com/VaccineApp/vaccine
$ cd vaccine
$ make
```

# Build flatpak
```Bash
$ flatpak-builder build org.vaccine.app.json
$ flatpak builder-export repo build
$ flatpak --user remote-add --no-gpg-verify --if-not-exists vaccine-local repo
$ flatpak --user install vaccine-local org.vaccine.app
$ flatpak run org.vaccine.app
```
