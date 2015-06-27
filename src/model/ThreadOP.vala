namespace Vaccine {
    public class ThreadOP : Post {
        public uint sticky          { get; set; }
        public uint closed          { get; set; }
        public string sub           { get; set; }
        public string semantic_url  { get; set; }
        public uint replies         { get; set; }
        public uint images          { get; set; }
        public uint bumplimit       { get; set; }
        public uint imagelimit      { get; set; }
        public uint unique_ips      { get; set; }
    }
}
