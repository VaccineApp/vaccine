public class Vaccine.PostTextBuffer : Object {
    private const MarkupParser parser = {
        visit_start,
        visit_end,
        visit_text,
        visit_passthrough,
        error
    };

    //private uint a_tag_level = 0; // handles nested <a> tags...thanks mods
    private MarkupParseContext ctx;
    private string src;
    private Gtk.TextView? text_view;
    private Gtk.TextBuffer buffer;
    private Gtk.TextIter iter;
    private string debug_text;

    private string current_tag = null;

    static string[]? style_scheme_ids { get; private set; }

    static construct {
        style_scheme_ids = Gtk.SourceStyleSchemeManager.get_default ().get_scheme_ids ();
        if (style_scheme_ids == null) {
            debug ("no style scheme IDs found for GtkSourceView");
            style_scheme_ids = { "" };
        } else
            foreach (var scheme in style_scheme_ids)
                debug ("found style scheme '%s'", scheme);
    }

    static List<Bayes.Guess> guess_language (string data) {
        return (Application.get_default () as App).code_classifier.guess (data);
    }

    void visit_start (MarkupParseContext context, string elem, string[] attrs, string[] vals) throws MarkupError {
        if (elem == "pre")
            current_tag = "code";
        if (elem == "b")
            current_tag = "bold";
        if (elem == "u")
            current_tag = "underline";
        if (elem == "math" || elem == "eqn")
            current_tag = "math";

        for (int i = 0; i < attrs.length; ++i) {
            if (elem == "span" && attrs[i] == "class" && vals[i] == "quote")
                current_tag = "greentext";
            if (elem == "a" && attrs[i] == "class" && vals[i] == "quotelink")
                current_tag = "link";
        }

        /*if (elem != "_top_level")
            debug_text += @"[$current_tag]";*/
    }

    void visit_text (MarkupParseContext context, string text, size_t text_len) throws MarkupError {
        bool inside_code = current_tag == "code";
        var link_regex = /(\w+:\/\/\S*)/;
        var tokens = inside_code ? new string[] { text } : link_regex.split (text);
        foreach (var elem in tokens) {
            if (!inside_code && link_regex.match (elem)) {
                buffer.insert_with_tags_by_name (ref iter, elem, -1, "link", current_tag);
                debug_text += elem;
            } else if (current_tag == "code" && text_view != null) {
                buffer.insert (ref iter, "\n", -1);
                Gtk.TextChildAnchor anchor = buffer.create_child_anchor (iter);
                Gtk.SourceView source_view = new Gtk.SourceView ();
                source_view.buffer.text = elem;

                // debug_text += @"\n[gtksourceview]$elem[/gtksourceview]\n";

                Gtk.SourceBuffer sbuffer = source_view.buffer as Gtk.SourceBuffer;
                sbuffer.style_scheme = Gtk.SourceStyleSchemeManager.get_default ().get_scheme ("tango");
                sbuffer.highlight_syntax = true;
                sbuffer.undo_manager = null;
                source_view.monospace = true;
                source_view.editable = false;
                source_view.input_hints = Gtk.InputHints.NONE;
                source_view.show_line_numbers = true;

                // guess programming language
                bool result_uncertain;
                string type = ContentType.guess (null, elem.data, out result_uncertain);
                debug ("GtkSourceView: type '%s' %s", type, result_uncertain ? "(uncertain)" : "");
                if (result_uncertain || type == "text/plain") {
                    List<Bayes.Guess> guesses = guess_language (elem);
                    string lang;
                    if (guesses != null) {
                        var best_guess = guesses.data;
                        debug ("guessing %s with probability %f",
                            best_guess.get_name (), best_guess.get_probability ());
                        lang = best_guess.get_name ();
                    } else {
                        debug ("could not guess language");
                        lang = "text";
                    }
                    sbuffer.language = Gtk.SourceLanguageManager.get_default ().get_language (lang);
                } else
                    sbuffer.language = Gtk.SourceLanguageManager.get_default ().guess_language (null, type);

                text_view.add_child_at_anchor (source_view, anchor);
                // FIXME: text_view does not resize properly (initially)
                text_view.show_all ();

                buffer.get_end_iter (out iter);
                buffer.insert (ref iter, "\n", -1);
            } else {
                // debug_text += elem;
                buffer.insert_with_tags_by_name (ref iter, elem, -1, current_tag);
            }
        }
    }

    void visit_end (MarkupParseContext context, string elem) throws MarkupError {
        /*if (elem != "_top_level")
            debug_text += @"[/$current_tag]";*/
        current_tag = null;
    }

    void visit_passthrough (MarkupParseContext context, string passthrough_text, size_t text_len) throws MarkupError {
        debug (@"visit_passthrough: $passthrough_text\n");
    }

    void error (MarkupParseContext context, Error error)  {
        debug (@"error: $(error.message)\n");
    }

    public PostTextBuffer (string com) {
        this.src = com;
        // debug_text = "";
        ctx = new MarkupParseContext(parser, 0, this, null);
    }

    public void fill_text_buffer (Gtk.TextBuffer buffer, Gtk.TextView? text_view) throws MarkupError {
        this.buffer = buffer;
        this.text_view = text_view;
        buffer.get_iter_at_offset (out this.iter, 0);
        var post = PostTransformer.common_clean (src);
        this.ctx.parse ("<_top_level>" + post + "</_top_level>", -1); // requires a top-level element
        // print (@"\n\x1b[35m==========================================\x1b[0m\n$src\n\t\t\t\t\x1b[44mv\x1b[0m\n$debug_text\n\n");
    }
}
