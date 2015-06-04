#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include <glib.h>
#include <glib/gprintf.h>
#include <gio/gunixoutputstream.h>
#include <json-glib/json-glib.h>
#include <libsoup/soup.h>
#include <gtk/gtk.h>

G_DEFINE_AUTOPTR_CLEANUP_FUNC(SoupSession, g_object_unref)
G_DEFINE_AUTOPTR_CLEANUP_FUNC(JsonParser, g_object_unref)
G_DEFINE_AUTOPTR_CLEANUP_FUNC(JsonGenerator, g_object_unref)
