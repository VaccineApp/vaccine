using Gee;

namespace Vaccine {
    public class FourChan : Object {
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
                debug (e.message);
            }
            return list;
        }

        /*
        public static async void update_thread (Thread thread) {
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
        }
        */

        public static async Thread get_thread (string board, int64 no) {
            var thread = new Thread (board);
            try {
                var json = new Json.Parser ();
                InputStream stream = yield soup.send_async (new Soup.Message ("GET", @"https://a.4cdn.org/$board/thread/$no.json"));
                if (yield json.load_from_stream_async (stream, null)) {
                    var posts_arr = json.get_root ().get_object ().get_array_member ("posts");
                    posts_arr.foreach_element ((arr, index, node) => {
                        if (index != 0) {
                            var p = Json.gobject_deserialize (typeof (Post), node) as Post;
                            p.thread = thread;
                            thread.posts.add (p);
                        } else {
                            var p = Json.gobject_deserialize (typeof (ThreadOP), node) as ThreadOP;
                            p.thread = thread;
                            thread.posts.add (p);
                        }
                    });
                }
            } catch (Error e) {
                debug (e.message);
            }
            return thread;
        }

        public static async Gdk.Pixbuf? get_thumbnail (Post p)
            requires (p.filename != null)
        {
            var url = @"https://i.4cdn.org/$(p.board)/$(p.tim)s.jpg";
            var msg = new Soup.Message ("GET", url);
            try {
                var stream = yield soup.send_async (msg);
                return yield new Gdk.Pixbuf.from_stream_async (stream, null);
            } catch (Error e) {
                debug (@"$(e.message) (board=$(p.thread == null))");
                return null;
            }
        }

        public static string get_tab_title (Thread thread) {
            var title = @"/$board/ - ";
            title += thread.op.sub ?? Stripper.transform_post(thread.op.com) ?? thread.op.no.to_string ();
            return Util.ellipsize(title, 32);
        }

        public static string get_post_text (string? com) {
            if (com == null)
                return "";
            try {
                return PostTransformer.transform_post (com);
            } catch (MarkupError e) {
                debug (e.message);
                return "";
            }
        }

        public static string get_post_time (uint time) {
            return new DateTime.from_unix_local (time).format ("%a, %b %e, %Y @ %l:%M %P");
        }
    }
}
