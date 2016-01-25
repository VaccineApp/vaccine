public interface Vaccine.NotebookPage : Gtk.Widget {
    public abstract void open_in_browser ();
    public abstract void filter (string text);
    public abstract void refresh ();
}
