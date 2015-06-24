string shorten (string s, uint lim) {
    var res = s.replace ("\n", " ");
    return res.length > lim ? res[0:lim] + "..." : res;
}
