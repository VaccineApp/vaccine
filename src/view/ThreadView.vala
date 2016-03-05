[GtkTemplate (ui = "/org/vaccine/app/ui/thread-view.ui")]
public class Vaccine.ThreadView : Gtk.Box, NotebookPage {
    [GtkChild] private Gtk.FlowBox list;

    string board;
    int64 no = -1;
    ListModel? model = null;

    public string search_text { get; set; }

    public ThreadView (string board, int64 no) {
        this.board = board;
        this.no = no;
    }

    public void set_model (ListModel model) {
        this.model = model;
        notify["search-text"].connect (() => {
            if (model is Thread) {
                ((Thread) model).set_filter (search_text);
            }
        });
        list.bind_model (model, item => {
            var post = item as Post;
            if (post.isOP && post.pixbuf == null)
                post.get_thumbnail (() => {});
            return new PostEntry (post, post.pixbuf);
        });
    }

    public void open_in_browser () {
        try {
            AppInfo.launch_default_for_uri ("https://boards.4chan.org/%s/thread/%lld".printf (board, no), null);
        } catch (Error e) {
            warning (e.message);
        }
    }

    public void refresh () {
        if (model is Thread) {
            ((Thread) model).update_thread ();
        }
    }
}
