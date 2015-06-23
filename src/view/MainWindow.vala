[GtkTemplate (ui = "/vaccine/main-window.ui")]
public class MainWindow : Gtk.ApplicationWindow {
    [GtkChild] private Gtk.ComboBoxText board_chooser;
    [GtkChild] private Gtk.Notebook notebook;

    public MainWindow (Vaccine app) {
        Object (application: app);

        board_chooser.changed.connect(ch => FourChan.board = ch.get_active_id ());

        FourChan.get_boards.begin ((obj, res) => {
            var boards = FourChan.get_boards.end (res);
            foreach (Board b in boards)
                board_chooser.append (b.board, @"/$(b.board)/ - $(b.title)");
        });

        var catalog = new CatalogWidget ();
        add_page (catalog, "Catalog", false);

        FourChan.catalog.downloaded.connect ((o, data) => {
            catalog.clear ();
            foreach (Page p in data)
                foreach (ThreadOP t in p.threads)
                    catalog.add (this, t);
        });

        this.show_all ();
    }

    public void show_thread (int64 no) {
        FourChan.get_thread.begin (no, (obj, res) => {
            var thread = FourChan.get_thread.end (res);
            var widget = new ThreadWidget (thread);
            var name = @"/$(FourChan.board)/$no";
            const int maxlen = 16;
            if (thread.op.sub != null)
                name += " - " + thread.op.sub.substring(0, maxlen) + "...";
            else if (thread.op.com != null)
                name += " - " + thread.op.com.substring(0, maxlen) + "...";
            add_page (widget, name, true);
        });
    }

    private void add_page (Gtk.Widget w, string t, bool c) {
        int i = notebook.append_page (w, new Tab (notebook, w, t, c));
        notebook.set_current_page (i);
    }
}
