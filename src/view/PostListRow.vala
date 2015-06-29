namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/post-list-row.ui")]
    public class PostListRow : Gtk.ListBoxRow {
        [GtkChild] private Gtk.Label post_name;
        [GtkChild] private Gtk.Label post_time;
        [GtkChild] private Gtk.Label post_number;
        [GtkChild] private Gtk.Label post_text;

        public PostListRow (Post t) {
            post_name.label = t.trip ?? t.name;
            post_time.label = new DateTime.from_unix_utc(t.time).format("%a, %b %e, %Y @ %l:%M %P");
            post_number.label = @"#$(t.no.to_string ())";
            post_text.label = t.com;
        }
    }
}
