using Gee;

public class ThreadWatcher : Object {
    Thread thread;

    public signal void new_post(Post p);

    public ThreadWatcher (Thread thread) {
        this.thread = thread;
        // set timer
    }
}
