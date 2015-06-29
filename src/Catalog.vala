using Gee;

namespace Vaccine {
    public class Catalog : Object {
        public signal void downloaded (ArrayList<Page> catalog);

        private async void real_download (string board) {
            var catalog = new ArrayList<Page> ();
            try {
                var json = new Json.Parser ();
                var stream = yield FourChan.soup.send_async (new Soup.Message ("GET", @"https://a.4cdn.org/$board/catalog.json"));
                if (yield json.load_from_stream_async (stream, null)) {
                    json.get_root ()
                        .get_array ()
                        .foreach_element ((arr, index, node) => {
                            var page = Json.gobject_deserialize (typeof (Page), node) as Page;
                            page.board = board;
                            foreach (var op in page.threads)
                                op.board = page.board;
                            catalog.add (page);
                        });
                }
            } catch (Error e) {
                debug (e.message);
            }
            downloaded (catalog);
        }

        public void download (string board)  {
            if (board != null && board != "")
                real_download.begin (board);
        }
    }
}
