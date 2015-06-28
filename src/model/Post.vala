namespace Vaccine {
    public class Post : Object {
        public int64 no             { get; set; }
        public string now           { get; set; }
        public string name          { get; set; }

        private string _com;
        public string com {
            get { return _com; }
            set { _com = FourChan.clean_comment (value); }
        }

        // image stuff
        public string? filename      { get; set; }
        public string? ext           { get; set; }
        public uint w               { get; set; }
        public uint h               { get; set; }
        public uint tn_w            { get; set; }
        public uint tn_h            { get; set; }
        public int64 tim            { get; set; }
        public string md5           { get; set; }
        public uint fsize           { get; set; }
        public uint spoiler         { get; set; }

        public uint time            { get; set; }
        // no of OP
        public uint resto           { get; set; }
        public string capcode       { get; set; }
        public string trip          { get; set; }

        public bool isOP { get { return resto == 0; } }
    }
}
