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

        public Post post { get; construct; }
        public Thread replies { get; private set; }

        public PostListRow (Post t) {
            Object (post: t);
            replies = get_all_replies ();
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

            post_text.label = FourChan.get_post_text (t.com);

            if (replies.posts.size == 0)
                responses_button.destroy ();
            else
                responses_button.set_tooltip_text (@"Show replies to #$(t.no)");
        }

        ~PostListRow () {
            if (cancel != null)
                cancel.cancel ();
        }

        private Thread get_all_replies () {
            return post.thread.filter ((p) => p.com != null && p.com.contains ("&gt;&gt;"+post.no.to_string ()));
        }

        [GtkCallback] private void show_responses () {
            var panelView = (get_ancestor (typeof (PanelView)) as PanelView);
            panelView.add (new ThreadPane (replies));
        }
    }
}
