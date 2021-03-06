[GtkTemplate (ui = "/org/vaccine/app/thread-pane.ui")]
public class Vaccine.ThreadPane : Gtk.Box, NotebookPage {
    [GtkChild] private unowned Gtk.ListBox list;
    [GtkChild] private unowned Gtk.Box heading_box;
    [GtkChild] private unowned Gtk.Label heading;

    public string search_text { get; set; }

    // we already have it from the catalog
    Gdk.Pixbuf? op_thumb;
    string board;
    int64 no = -1;
    ListModel? model = null;

    // UI is prioritized, call set_model later when you have data
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
            return new PostListRow (post, post.isOP ? op_thumb : null);
        });
    }

    public ThreadPane (string board, int64 no, Gdk.Pixbuf? op_thumb = null) {
        this.board = board;
        this.no = no;
        this.op_thumb = op_thumb;
    }

    public ThreadPane.with_title (string title) {
        // OP could theoretically guess the post number
        // assert (!model.get_item (0).isOP);
        heading_box.visible = true;
        heading.label = "<span size=\"large\">" + title + "</span>";
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
