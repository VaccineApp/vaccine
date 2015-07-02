namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/post-list-row.ui")]
    public class PostListRow : Gtk.ListBoxRow {
        [GtkChild] private Gtk.Label post_name;
        [GtkChild] private Gtk.Label post_time;
        [GtkChild] private Gtk.Label post_number;
        [GtkChild] private Gtk.Label post_text;

        public PostListRow (Post t) {
            post_name.label = t.name + (t.trip ?? "");
            post_time.label = FourChan.get_post_time (t.time);
            post_number.label = @"#$(t.no.to_string ())";
            post_text.label = FourChan.get_post_text (t.com);
        }
    }
}
