public class Board : Object {
    public string board           { get; set; }
    public string title           { get; set; }
    public uint ws_board          { get; set; }
    public uint per_page          { get; set; }
    public uint pages             { get; set; }
    public uint max_filesize      { get; set; }
    public uint max_webm_filesize { get; set; }
    public uint max_comment_chars { get; set; }
    public uint bump_limit        { get; set; }
    public uint image_limit       { get; set; }

    public class Cooldowns : Object {
        public uint threads        { get; set; }
        public uint replies        { get; set; }
        public uint images         { get; set; }
        public uint replies_uintra { get; set; }
        public uint images_uintra  { get; set; }
    }

    public Cooldowns cooldowns    { get; set; }
    public uint user_ids          { get; set; }
    public uint spoilers          { get; set; }
    public uint custom_spoilers   { get; set; }
    public uint is_archived       { get; set; }
    public uint country_flags     { get; set; }
    public uint math_tags         { get; set; }
    public uint code_tags         { get; set; }
}
