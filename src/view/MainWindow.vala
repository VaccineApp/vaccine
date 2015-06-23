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
            Thread thread = FourChan.get_thread.end (res);
            var widget = new ThreadWidget (thread);

            string cont;
                 if (thread.op.sub != null && thread.op.sub.strip ().char_count () != 0) cont = thread.op.sub;
            else if (thread.op.com != null && thread.op.com.strip ().char_count () != 0) cont = thread.op.com;
            else cont = thread.op.no.to_string ();

            if (cont.char_count () > 16) cont = cont.substring (0, 16) + "...";

            string name = @"/$(FourChan.board)/ - $cont";
            add_page (widget, name, true);
        });
    }

    private void add_page (Gtk.Widget w, string t, bool c) {
        int i = notebook.append_page (w, new Tab (notebook, w, t, c));
        notebook.set_current_page (i);
    }
}
