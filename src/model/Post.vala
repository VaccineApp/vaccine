public class Post : Object {
    public int64 no             { get; set; }
    public string now           { get; set; }
    public string name          { get; set; }
    public string com           { get; set; }

    // image stuff
    public string filename      { get; set; }
    public string ext           { get; set; }
    public uint w               { get; set; }
    public uint h               { get; set; }
    public uint tn_w            { get; set; }
    public uint tn_h            { get; set; }
    public int64 tim            { get; set; }
    public string md5           { get; set; }
    public uint fsize           { get; set; }

    public uint time            { get; set; }
    // no of OP
    public uint resto           { get; set; }
    public string capcode       { get; set; }
    public string trip          { get; set; }

    public bool isOP { get { return resto == 0; } }
}

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