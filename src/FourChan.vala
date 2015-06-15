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

    // do we even need this?
    public async Board? get_board_obj (string id) {
        var boards = yield get_boards ();
        foreach (Board x in boards)
            if (x.board == id)
                return x;
        return null;
    }

    public ThreadWatcher[] watched;
//    public ThreadWatcher watch_thread (Thread t);
}

public class ThreadWatcher : Object {
    Thread thread;

    public signal void new_post(Post p);

    public ThreadWatcher (Thread thread) {
        this.thread = thread;
        // set timer
    }
}
