public class Board : Object {
    public string board          { get; set; }
    public string title          { get; set; }
    public int ws_board          { get; set; }
    public int per_page          { get; set; }
    public int pages             { get; set; }
    public int max_filesize      { get; set; }
    public int max_webm_filesize { get; set; }
    public int max_comment_chars { get; set; }
    public int bump_limit        { get; set; }
    public int image_limit       { get; set; }

    public class Cooldowns : Object {
        public int threads       { get; set; }
        public int replies       { get; set; }
        public int images        { get; set; }
        public int replies_intra { get; set; }
        public int images_intra  { get; set; }
    }

    public Cooldowns cooldowns   { get; set; }
    public int user_ids          { get; set; }
    public int spoilers          { get; set; }
    public int custom_spoilers   { get; set; }
    public int is_archived       { get; set; }
    public int country_flags     { get; set; }
    public int math_tags         { get; set; }
    public int code_tags         { get; set; }
}
