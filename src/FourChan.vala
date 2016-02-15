using Gee;

public class Vaccine.FourChan : Object {
    public static Catalog catalog = new Catalog ();
    public static Soup.Session soup = new Soup.Session ();

    // NOTE: pass to function if it is async,
    // otherwise function can access it directly
    private static string _board; // TODO: save & restore
    public static string board {
        get { return _board; }
        set {
            _board = value;
            catalog.download.begin (_board);
        }
    }

    // TODO: do once in constructor and save result?
    public static async ArrayList<Board> get_boards () {
        var list = new ArrayList<Board> ();
        try {
            var json = new Json.Parser ();
            InputStream stream = yield soup.send_async (new Soup.Message ("GET", "https://a.4cdn.org/boards.json"));
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
            new ErrorDialog (e.message);
            error (e.message);
        }
        return list;
    }

    public static async void dl_thread (Thread thread) {
        try {
            var json = new Json.Parser ();
            InputStream stream = yield soup.send_async (new Soup.Message ("GET",
                "https://a.4cdn.org/%s/thread/%lld.json".printf (thread.board, thread.no)));
            if (yield json.load_from_stream_async (stream, null)) {
                var posts = new ArrayList<Post> ();
                json.get_root ()
                    .get_object ()
                    .get_array_member ("posts")
                    .foreach_element ((arr, index, node) => {
                        Post p;
                        if (index == 0) p = Json.gobject_deserialize (typeof (ThreadOP), node) as ThreadOP;
                        else            p = Json.gobject_deserialize (typeof (Post), node) as Post;
                        assert (p != null);
                        p.thread = thread;
                        posts.add (p);
                    });
                if (thread.posts == null) {
                    thread.posts = posts;
                    thread.items_changed (0, 0, posts.size);
                } else {
                    // update thread
                    int old_n_posts = thread.posts.size;
                    uint added = 0;
                    for (int i = 0; i < posts.size; ++i) {
                        if (i > thread.posts.size-1) { // new post
                            thread.posts.add (posts[i]);
                            ++added;
                        } else if (thread.posts[i].no != posts[i].no) { // post deleted
                            thread.posts.remove_at (i);
                            thread.items_changed (i, 1, 0);
                            --i;
                        }
                    }
                    if (added > 0) {
                        thread.items_changed (old_n_posts, 0, added);
                    }
                }
            }
        } catch (Error e) {
            new ErrorDialog (e.message);
            error (e.message);
        }
    }

    public static async Gdk.PixbufAnimation? download_image (string url, Cancellable cancel) {
        var msg = new Soup.Message ("GET", url);
        try {
            var stream = yield soup.send_async (msg, cancel);
            return yield new Gdk.PixbufAnimation.from_stream_async (stream, cancel);
        } catch (Error e) {
            debug (e.message);
            return null;
        }
    }

    public static string get_post_time (uint time) {
        return new DateTime.from_unix_local (time).format ("%a, %b %e, %Y @ %l:%M %P");
    }
}
