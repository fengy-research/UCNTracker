namespace GLib {
	namespace Log {
		public extern void default_handler(string log_domain, LogLevelFlags flags, string message, void* data);
	}
}
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public PluginModuleManager manager = null;
	private UniqueRNG dummy_unique_rng = null;
	public bool init([CCode (array_length_pos = 0.9)] ref unowned string[] args) {
		manager = new PluginModuleManager();
		set_absolutely_quiet(false);
		set_verbose(false);
		/* To initialize the unique rng*/
		dummy_unique_rng = new UniqueRNG();
		return true;
	}
	/**
	 * No criticals and warnings will be reported to the console when set.
	 */
	public void set_absolutely_quiet(bool quiet) {
		if(!quiet) {
			Log.set_handler("UCNTracker", LogLevelFlags.LEVEL_CRITICAL, (LogFunc) Log.default_handler);
			Log.set_handler("UCNTracker", LogLevelFlags.LEVEL_WARNING, (LogFunc) Log.default_handler);
		} else {
			Log.set_handler("UCNTracker", LogLevelFlags.LEVEL_CRITICAL, (LogFunc) void_handler);
			Log.set_handler("UCNTracker", LogLevelFlags.LEVEL_WARNING, (LogFunc) void_handler);
		}
		
	}
	/**
	 * Debugging messages are written to the console if set
	 */
	public void set_verbose(bool verbose) {
		if(verbose) {
			Log.set_handler("UCNTracker", LogLevelFlags.LEVEL_DEBUG, (LogFunc) Log.default_handler);
		} else {
			Log.set_handler("UCNTracker", LogLevelFlags.LEVEL_DEBUG, (LogFunc) void_handler);
		}
	}
	private void void_handler(string? domain, LogLevelFlags level, string? message, void* data) {
	}
}
