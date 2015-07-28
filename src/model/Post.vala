namespace Vaccine {
    public class Post : Object {
        /**
         * Post number
         */
        public int64 no             { get; set; }

        /**
         * Reply to
         */
        public uint resto           { get; set; }

        /**
         * Date and time
         *
         * Format: MM/DD/YY(Day)HH:MM
         * Some boards have :SS.
         * Time is in EST/EDT
         */
        public string now           { get; set; }

        /**
         * Unix timestamp
         */
        public uint time            { get; set; }

        /**
         * Name
         */
        public string name          { get; set; }

        /**
         * Tripcode
         *
         * Format:
         *      !tripcode
         *      !!securetripcode
         */
        public string? trip         { get; set; }

        /**
         * ID
         * Mod, Admin, Developer
         */
        public string? id           { get; set; }

        /**
         * Capcode
         *
         * none, mod, admin, admin_highlight, developer
         */
        public string? capcode      { get; set; }

        /**
         * Country code
         * 2 characters, ISO-3166-1 alpha-2
         */
        public string? country      { get; set; }

        /**
         * Comment
         */
        public string com           { get; set; }

        /**
         * Renamed filename
         * Unix timestamp + milliseconds
         */
        public int64 tim            { get; set; }

        /**
         * Original filename
         */
        public string? filename     { get; set; }

        /**
         * File extension
         */
        public string? ext          { get; set; }

        /**
         * File size
         */
        public uint fsize           { get; set; }

        /**
         * Image width
         */
        public uint w               { get; set; }

        /**
         * Image height
         */
        public uint h               { get; set; }

        /**
         * Thumbnail width
         */
        public uint tn_w            { get; set; }

        /**
         * Thumbnail height
         */
        public uint tn_h            { get; set; }

        /**
         * File MD5
         * 24 chars, base64
         */
        public string? md5          { get; set; }

        /**
         * File deleted?
         */
        public uint filedeleted     { get; set; }

        /**
         * Spoiler image?
         */
        public uint spoiler         { get; set; }

        /**
         * Custom spoilers?
         *
         * 1-99
         */
        public uint custom_spoiler  { get; set; }


        // begin vaccine stuff
        public bool isOP { get { return resto == 0; } }

        public weak Thread? thread = null;

        private string _board;
        public string board {
            get { return thread != null ? thread.board : _board; }
            set { _board = value; }
        }
    }

    public class ThreadOP : Post {
        /**
         * Stickied thread?
         */
        public uint sticky          { get; set; }

        /**
         * Closed thread?
         */
        public uint closed          { get; set; }

        /**
         * Archived thread?
         */
        public uint archived          { get; set; }

        /**
         * Subject
         */
        public string sub           { get; set; }

        /**
         * Thread URL slug
         */
        public string semantic_url  { get; set; }

        /**
         * Thread tag
         */
        public string tag           { get; set; }

        /**
         * Number of total replies
         */
        public uint replies         { get; set; }

        /**
         * Number of total images
         */
        public uint images          { get; set; }

        /**
         * Bump limit met?
         */
        public uint bumplimit       { get; set; }

        /**
         * Image limit met?
         */
        public uint imagelimit      { get; set; }

        /**
         * Unique IPs participated in this thread
         */
        public uint unique_ips      { get; set; }
    }
}
