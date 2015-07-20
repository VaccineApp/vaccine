namespace Vaccine {
    [GtkTemplate (ui = "/vaccine/post-list-row.ui")]
    public class PostListRow : Gtk.ListBoxRow {
        // still unsure about showing time, id, etc...
        /*
        [GtkChild] private Gtk.Label post_time;
        [GtkChild] private Gtk.Label post_name;
        [GtkChild] private Gtk.Label post_id;
        */
        [GtkChild] private Gtk.Label post_text;
        [GtkChild] private Gtk.Image post_thumbnail;
        [GtkChild] private Gtk.Button image_button;
        [GtkChild] private Gtk.Button responses_button;

        private Cancellable? cancel = null;

        public PostListRow (Post t) {
            /*
            post_time.label = FourChan.get_post_time (t.time);
            post_id.label = @"#$(t.no)";
            post_name.label = t.name;
            */
            if (t.filename == null) {
                image_button.destroy ();
            } else {
                cancel = FourChan.get_thumbnail (t, buf => {
                    cancel = null;
                    post_thumbnail.pixbuf = buf;
                });
            }

            responses_button.clicked.connect(() => {
                PanelView view = get_ancestor (typeof (PanelView)) as PanelView;
                Thread replies = t.thread.filter ((post) => post.com.contains ("&gt;&gt;"+t.no.to_string ()));
                foreach (var post in replies.posts) // for debug
                    stdout.printf ("reply: %s\n", post.com);
                if (replies.posts.size > 0)
                    view.add (new ThreadPane (replies));
            });

            post_text.label = FourChan.get_post_text (t.com);
        }

        ~PostListRow () {
            if (cancel != null)
                cancel.cancel ();
        }
    }
}
