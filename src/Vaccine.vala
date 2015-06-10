public class Vaccine : Gtk.Application {
    public Vaccine () {
        Object (application_id: "popcnt.Vaccine", flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate () {
        new MainWindow (this);
    }
}

/*
void demo () throws Error {
    var choice = stdin.read_line ();
    var catalog_json = sess.send (new Soup.Message ("GET", @"https://a.4cdn.org/$choice/catalog.json"));
    parser.load_from_stream (catalog_json);
    parser.get_root ().get_array ().foreach_element ((arr, index, node) => {
        var p = Json.gobject_deserialize(typeof (Page), node) as Page;
        if (p != null) {
            print (@"Page #$(p.page)\n");
            for (int i = 0; i < p.threads.length; ++i) {
                var ti = p.threads.index(i);
                print (@"\t$ti\n");
            }
        }
    });
}
*/

int main (string[] args) {
    var app = new Vaccine ();
    return app.run (args);
}
