[GtkTemplate (ui = "/org/vaccine/app/catalog-item.ui")]
public class Vaccine.CatalogItem : Gtk.Button {
    // TODO: show # of replies (and make it look good)
    private weak MainWindow main_window;

    [GtkChild] private unowned Gtk.Stack image_stack;

    [GtkChild] public unowned Gtk.Label post_subject;
    [GtkChild] public unowned Gtk.Label post_comment;
    [GtkChild] public unowned Gtk.Label post_n_replies;

    private Cancellable? cancel = null;

    public ThreadOP op { get; construct; }

    public CatalogItem (MainWindow win, ThreadOP t) {
        Object (op: t);
        this.main_window = win;

        if (t.filename != null) { // deleted files
            cancel = t.get_thumbnail (buf => {
                cancel = null;
                var image = new CoverImage (buf);
                image_stack.add (image);
                image_stack.set_visible_child (image);
            });
        }
        if (t.com != null)
            this.post_comment.label = PostTransformer.transform_post (t.com);
        this.post_n_replies.label = "%u replies".printf (t.replies);
        if (t.sub != null)
            this.post_subject.label = "<span weight=\"bold\" size=\"larger\">%s</span>".printf (t.sub);
        else
            post_subject.destroy ();
    }

    ~CatalogItem () {
        if (cancel != null)
            cancel.cancel ();
    }

    [GtkCallback]
    public void show_thread () {
        main_window.show_thread (op.no, op.pixbuf);
    }
}
