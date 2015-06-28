namespace Vaccine {
    public class Board : Object {
        /**
         * Short board code
         */
        public string board            { get; set; }

        /**
         * Full board name
         */
        public string title            { get; set; }

        /**
         * Safe for work
         */
        public uint ws_board           { get; set; }

        /**
         * Threads per page
         */
        public uint per_page           { get; set; }

        /**
         * Number of pages
         */
        public uint pages              { get; set; }

        /**
         * Maximum filesize
         */
        public uint max_filesize       { get; set; }

        /**
         * Maximum webm filesize
         */
        public uint max_webm_filesize  { get; set; }

        /**
         * Maximum length of comment
         */
        public uint max_comment_chars  { get; set; }

        /**
         * Maximum number of posts that can bump a thread
         */
        public uint bump_limit         { get; set; }

        /**
         * Maximum number of images that can be posted in a thread
         */
        public uint image_limit        { get; set; }

        public class Cooldowns : Object {
            public uint threads        { get; set; }
            public uint replies        { get; set; }
            public uint images         { get; set; }
            public uint replies_uintra { get; set; }
            public uint images_uintra  { get; set; }
        }

        public Cooldowns cooldowns     { get; set; }
        public uint user_ids           { get; set; }

        /**
         * Whether this board support spoilers
         */
        public uint spoilers           { get; set; }
        public uint custom_spoilers    { get; set; }

        /**
         * Whether this board is archived
         */
        public uint is_archived        { get; set; }

        /**
         * Whether this board supports country flags
         */
        public uint country_flags      { get; set; }

        /**
         * Whether this board supports math tags
         */
        public uint math_tags          { get; set; }

        /**
         * Whether this board supports code tags
         */
        public uint code_tags          { get; set; }
    }
}
