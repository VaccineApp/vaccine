public interface Vaccine.NotebookPage : Gtk.Widget {
    public abstract string search_text { get; set; }
    public abstract void open_in_browser ();
    public abstract void refresh ();
}
