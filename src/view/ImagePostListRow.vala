namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/image-post-list-row.ui")]
    public class ImagePostListRow : Gtk.ListBoxRow {
        [GtkChild] private Gtk.Label post_name;
        [GtkChild] private Gtk.Label post_time;
        [GtkChild] private Gtk.Label post_number;
        [GtkChild] private Gtk.Label post_text;

        [GtkChild] private Gtk.Label post_thumbnail_filename;
        [GtkChild] private Gtk.Image post_thumbnail;

        public ImagePostListRow (Post t)
        {
            post_name.label = t.name + (t.trip ?? "");
            post_time.label = new DateTime.from_unix_utc(t.time).format("%a, %b %e %Y @ %l:%M %P");
            post_number.label = @"#$(t.no.to_string ())";
            post_text.label = t.com;

            post_thumbnail_filename.label = t.filename + t.ext;
            FourChan.get_thumbnail.begin (t, (obj, res) => {
                post_thumbnail.pixbuf = FourChan.get_thumbnail.end (res);
            });
        }
    }
}
