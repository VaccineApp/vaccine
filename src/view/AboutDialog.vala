[GtkTemplate (ui = "/org/vaccine/app/about-dialog.ui")]
public class Vaccine.AboutDialog : Gtk.AboutDialog {
    private MainWindow parent_win;

    public AboutDialog (Gtk.ApplicationWindow app_window) {
        version = PROGRAM_VERSION;
        set_transient_for (app_window);
        parent_win = app_window as MainWindow;
        ++parent_win.dialogs;
    }

    public override void destroy () {
        --parent_win.dialogs;
        base.destroy ();
    }
}
