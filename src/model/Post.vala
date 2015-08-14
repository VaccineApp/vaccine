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

        public Gdk.Pixbuf? pixbuf { get; private set; default = null; }

        public delegate void UseDownloadedPixbuf (Gdk.Pixbuf buf);

        public Cancellable get_thumbnail (UseDownloadedPixbuf cb)
            requires (filename != null)
        {
            var url = "https://i.4cdn.org/%s/%llds.jpg".printf (board, tim);
            var cancel = new Cancellable ();
            if (pixbuf == null)
                FourChan.download_image.begin (url, cancel, (obj, res) => {
                    pixbuf = FourChan.download_image.end (res);
                    if (!cancel.is_cancelled () && pixbuf != null)
                        cb ((!) pixbuf);
                });
            else
                cb ((!) pixbuf);
            return cancel;
        }

        public Gdk.Pixbuf? full_pixbuf { get; private set; default = null; }

        public Cancellable get_full_image (UseDownloadedPixbuf cb)
            requires (filename != null && ext != null)
        {
            var url = @"https://i.4cdn.org/$board/$tim$ext";
            var cancel = new Cancellable ();
            if (full_pixbuf == null)
                FourChan.download_image.begin (url, cancel, (obj, res) => {
                    full_pixbuf = FourChan.download_image.end (res);
                    if (!cancel.is_cancelled () && full_pixbuf != null)
                        cb ((!) full_pixbuf);
                });
            else
                cb ((!) full_pixbuf);
            return cancel;
        }


        public uint nreplies {
            get {
                var quote = "&gt;&gt;%lld".printf (no);
                uint n = 0;
                foreach (var p in thread.posts)
                    if (p.com != null && p.com.contains (quote))
                        ++n;
                return n;
            }
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
