class Bloop : Object {
    static void demo() throws Error {
        var sess = new Soup.Session();
        var boards_json = sess.send(new Soup.Message("GET", "https://a.4cdn.org/boards.json"));

        var parser = new Json.Parser();
        parser.load_from_stream(boards_json);
        var boards = parser.get_root().get_object().get_array_member("boards");
        boards.foreach_element((arr, index, node) => {
            var b = Json.gobject_deserialize(typeof(Board), node) as Board;
            if (b != null) stdout.printf(@"/$(b.board)/ ");
        });

        stdout.printf("\nChoose a board: ");
        var choice = stdin.read_line();
        var threads_json = sess.send(new Soup.Message("GET", @"https://a.4cdn.org/$choice/threads.json"));
        parser.load_from_stream(threads_json);
        parser.get_root().get_array().foreach_element((arr, index, node) => {
            var p = Json.gobject_deserialize(typeof(Page), node) as Page;
            if (p != null) stdout.printf(@"$p\n");
        });
    }

    static void main(string[] args) {
        try {
            demo();
        } catch (Error e) {
            stderr.printf("Error: " + e.message);
        }
    }
}
