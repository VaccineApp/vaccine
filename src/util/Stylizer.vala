namespace Vaccine {
    public class Stylizer {
        public static void set_widget_css (Gtk.Widget w, string resource) {
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource (resource);
            Gtk.StyleContext.add_provider_for_screen (
                w.get_screen (),
                provider,
                0
            );
        }
    }
}
