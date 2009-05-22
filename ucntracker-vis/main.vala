[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public static bool vis_initialized = false;
	public static bool vis_init([CCode (array_length_pos = 0.9)] ref unowned string[]? args = null) {
		Gtk.init(ref args);
		Gtk.gl_init (ref args);
		vis_initialized = true;
		return true;
	}
}
