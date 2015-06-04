public class Page {
    public int page { get; set; }

    public class ThreadInfo {
        public int no { get; set; }
        public int last_modified { get; set; }
    }

    public ThreadInfo[] threads { get; set; }
}
