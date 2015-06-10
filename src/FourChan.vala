public class FourChan : Object {
    public delegate void UseBoard (Board b);

    public static async void foreach_board (UseBoard func) {
        var sess = new Soup.Session ();
        var req = new Soup.Message ("GET", "https://a.4cdn.org/boards.json");

        InputStream stream;
        try {
            stream = yield sess.send_async (req, null);
        } catch (Error e) {
            error (e.message);
        }

        var parser = new Json.Parser ();
        bool json_parsed = false;
        try {
            json_parsed = yield parser.load_from_stream_async (stream, null);
        } catch (Error e) {
            error (e.message);
        }

        if (json_parsed) {
            var boards = parser.get_root ().get_object ().get_array_member ("boards");
            boards.foreach_element ((arr, index, node) => {
                var b = Json.gobject_deserialize (typeof (Board), node) as Board;
                if (b != null)
                    func (b);
            });
        }
    }

    public delegate void UseThread (ThreadInfo ti);

    public static async void foreach_catalog (UseThread func) {
        var sess = new Soup.Session ();
        var req = new Soup.Message ("GET", "https://a.4cdn.org/g/catalog.json");

        InputStream stream;
        try {
            stream = yield sess.send_async (req, null);
        } catch (Error e) {
            error (e.message);
        }

        var parser = new Json.Parser ();
        bool json_parsed = false;
        try {
            json_parsed = yield parser.load_from_stream_async (stream, null);
        } catch (Error e) {
            error (e.message);
        }

        if (json_parsed) {
            parser.get_root ().get_array ().foreach_element ((arr, index, node) => {
                var page = Json.gobject_deserialize (typeof (Page), node) as Page;
                if (page != null) {
                    foreach (var ti in page.threads) {
                        func (ti);
                    }
                }
            });
        }
    }
}
