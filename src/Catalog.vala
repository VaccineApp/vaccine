using Gee;

public class Vaccine.Catalog : Object {
    public signal void downloaded (string board, ArrayList<Page> catalog);

    public async void download (string board)
    {
        if (board.length == 0)
            return; // can't have requires () on an async function?
        var catalog = new ArrayList<Page> ();
        try {
            var json = new Json.Parser ();
            var stream = yield FourChan.soup.send_async (new Soup.Message ("GET", @"https://a.4cdn.org/$board/catalog.json"));
            if (yield json.load_from_stream_async (stream, null)) {
                json.get_root ()
                    .get_array ()
                    .foreach_element ((arr, index, node) => {
                        var page = Json.gobject_deserialize (typeof (Page), node) as Page;
                        assert (page != null);
                        page.board = board;
                        foreach (var op in page.threads)
                            op.board = board;
                        catalog.add (page);
                    });
            }
        } catch (Error e) {
            debug (e.message);
        }
        downloaded (board, catalog);
    }
}
