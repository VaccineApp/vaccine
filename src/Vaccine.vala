public class Vaccine : Gtk.Application {
    public Vaccine () {
        Object (application_id: "popcnt.Vaccine", flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate () {
        new MainWindow (this);
    }
}
