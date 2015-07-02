namespace Vaccine {
    namespace Util {
        string ellipsize (string s, uint lim) {
            return s.length > lim ? s[0:lim] + "..." : s;
        }

        public class StringModifier : Object {
            public string text { get; private set; }

            public StringModifier (string text) {
                this.text = text;
            }

            public StringModifier replace (Regex exp, string replacement) {
                try {
                    text = exp.replace (text, -1, 0, replacement);
                } catch (Error e) {
                    debug (e.message);
                }
                return this;
            }

            public StringModifier replace_text (string find, string replacement) {
                text = text.replace (find, replacement);
                return this;
            }

            public StringModifier remove (string rm) {
                return this.replace_text (rm, "");
            }
        }
    }
}
