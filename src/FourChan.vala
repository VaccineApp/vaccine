using Gee;

public class FourChan : Object {
    public static Catalog catalog = new Catalog ();
    public static Soup.Session soup = new Soup.Session ();

    private static string _board; // TODO: save & restore
    public static string board {
        get { return _board; }
        set {
            _board = value;
            catalog.download (_board);
        }
    }

    // TODO: do once in constructor and save result?
    public static async ArrayList<Board> get_boards () {
        var list = new ArrayList<Board> ();
        try {
            var json = new Json.Parser ();
            var stream = yield soup.send_async (new Soup.Message ("GET", "https://a.4cdn.org/boards.json"));
            if (yield json.load_from_stream_async (stream, null)) {
                json.get_root ()
                    .get_object ()
                    .get_array_member ("boards")
                    .foreach_element ((arr, index, node) => {
                        var board = Json.gobject_deserialize (typeof (Board), node) as Board;
                        list.add (board);
                    });
            }
        } catch (Error e) {
            debug (e.message);
        }
        return list;
    }

/*    public static async void update_thread (Thread thread) {
        try {
            var json = new Json.Parser ();
            var thread_no = thread.posts[0].no;
            var stream = yield soup.send_async (new Soup.Message ("GET", @"https://a.4cdn.org/$board/thread/$thread_no.json"));
            if (yield json.load_from_stream_async (stream, null)) {
                var posts_arr = json.get_root ().get_object ().get_array_member ("posts");
                int i = 0;
                posts_arr.foreach_element ((arr, index, node) => {
                    int64 no = node.get_object ().get_int_member ("no");
                    if (i >= thread.posts.size || thread.posts[i].no != no) {
                        var p = Json.gobject_deserialize (typeof (Post), node) as Post;
                        thread.posts.add (p);
                    }
                    ++i;
                });
            }
        } catch (Error e) {
            debug (e.message);
        }
    }*/

    public static async Thread get_thread (int64 no) {
        var thread = new Thread ();
        try {
            var json = new Json.Parser ();
            var stream = yield soup.send_async (new Soup.Message ("GET", @"https://a.4cdn.org/$board/thread/$no.json"));
            if (yield json.load_from_stream_async (stream, null)) {
                var posts_arr = json.get_root ().get_object ().get_array_member ("posts");
                thread.posts.add (Json.gobject_deserialize (typeof (ThreadOP), posts_arr.get_element (0)) as ThreadOP);
                posts_arr.foreach_element ((arr, index, node) => {
                    if (index != 0) {
                        var p = Json.gobject_deserialize (typeof (Post), node) as Post;
                        thread.posts.add (p);
                    }
                });
            }
        } catch (Error e) {
            debug (e.message);
        }
        return thread;
    }

    public static async Gdk.Pixbuf? get_thumbnail (Post p) {
        assert (p.filename != null);

        var url = @"https://i.4cdn.org/$board/$(p.tim)s.jpg";
        var msg = new Soup.Message ("GET", url);
        try {
            var stream = yield soup.send_async (msg);
            return yield new Gdk.Pixbuf.from_stream_async (stream, null);
        } catch (Error e) {
            debug (e.message);
            return null;
        }
    }

    public static string clean_comment (string com) {
        return com
            .compress ()
            .replace("<br>", "\n")
            .replace("<wbr>", "")
            .replace(" target=\"_blank\"", "")
            .replace(" class=\"quote\"", "")
            .replace(" class=\"quotelink\"", "");
    }
}

