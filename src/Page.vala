public class Page : Object {
    public int page { get; set; }

    public class ThreadInfo : Object {
        public int no            { get; set; }
        public int last_modified { get; set; }
    }

    // always empty
    public ThreadInfo[] threads { get; set; }
}
