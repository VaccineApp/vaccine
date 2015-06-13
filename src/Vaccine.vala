public class Vaccine : Gtk.Application {
    public Vaccine () {
        Object (application_id: "popcnt.Vaccine", flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate () {
        new MainWindow (this);
    }
}

int main (string[] args) {
    var app = new Vaccine ();
    return app.run (args);
}
