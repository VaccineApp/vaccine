using Gee;

public class FourChan : Object {
    private static FourChan instance;
    public static new FourChan get () {
        if (instance == null)
            instance = new FourChan ();
        return instance;
    }
    
    private Soup.Session soup = new Soup.Session ();

    ~FourChan () {
        soup.abort ();
    }

    private string _cur_board;
    public string cur_board {
        get {
            return _cur_board;
        }
        set {
            _cur_board = value;
            refresh_catalog.begin ();
        }
        default = "g"; // TODO: save & restore
    }

    public signal void catalog_updated (ArrayList<Page> catalog);

    public async void refresh_catalog ()  {
        var catalog = new ArrayList<Page> ();
        try {
            var json = new Json.Parser ();
            var stream = yield soup.send_async (new Soup.Message ("GET", @"https://a.4cdn.org/$cur_board/catalog.json"));
            if (yield json.load_from_stream_async (stream, null)) {
                json.get_root ()
                    .get_array ()
                    .foreach_element ((arr, index, node) => {
                        var page = Json.gobject_deserialize (typeof (Page), node) as Page;
                        catalog.add (page);
                    });
            }
        } catch (Error e) {
            debug (e.message);
        }
        catalog_updated (catalog);
    }

    // TODO: do once in constructor and save result
    public async ArrayList<Board> get_boards () {
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

    public async void update_thread (Thread thread) {
        try {
            var json = new Json.Parser ();
            var thread_no = thread.posts[0].no;
            var stream = yield soup.send_async (new Soup.Message ("GET", @"https://a.4cdn.org/$cur_board/thread/$thread_no.json"));
            if (yield json.load_from_stream_async (stream, null)) {
                var posts_arr = json.get_root ().get_object ().get_array_member ("posts");
                int i = 0;
                posts_arr.foreach_element ((arr, index, node) => {
                    int64 no = node.get_object ().get_int_member ("no");
                    if (i < thread.posts.size && thread.posts[i].no != no) {
                        var p = Json.gobject_deserialize (typeof (Post), node) as Post;
                        thread.posts.add (p);
                    }
                    ++i;
                });
            }
        } catch (Error e) {
            debug (e.message);
        }
    }

    public async Gdk.Pixbuf load_post_thumbnail (Post p) {
        assert (p.filename != null);

        var url = @"https://i.4cdn.org/$cur_board/$(p.tim)s.jpg";
        var msg = new Soup.Message ("GET", url);
        var stream = yield soup.send_async (msg);
        return yield new Gdk.Pixbuf.from_stream_async (stream, null);
    }

    public ThreadWatcher[] watched;
//    public ThreadWatcher watch_thread (Thread t);
}

