[GtkTemplate (ui = "/org/vaccine/app/thread-pane.ui")]
public class Vaccine.ThreadPane : Gtk.Box {
    [GtkChild] private Gtk.ListBox list;
    [GtkChild] private Gtk.Box heading_box;
    [GtkChild] private Gtk.Label heading;
    [GtkChild] private Gtk.Button closebutton;

    public ListModel model { get; construct; }

    private void add_separator (Gtk.ListBoxRow row, Gtk.ListBoxRow? before) {
        if (before != null && row.get_header () == null)
            row.set_header (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
    }

    public ThreadPane (ListModel model, Gdk.Pixbuf? op_thumb = null) {
        Object (model: model);
        closebutton.margin = 5;
        list.set_header_func (add_separator);
        list.bind_model (model, item => {
            var post = item as Post;
            return new PostListRow (post, post.isOP ? op_thumb : null);
        });
    }

    public ThreadPane.with_replies (ListModel model, string title) {
        this (model);
        // ebin OP sometimes guesses the post number
        // assert (!model.get_item (0).isOP);
        heading_box.visible = true;
        heading.label = @"<span size=\"large\">$title</span>";
    }
}
