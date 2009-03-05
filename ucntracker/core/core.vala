using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	[CCode (cname = "ucn_core_init")]
	[ModuleInit]
	public bool core_init(TypeModule module) {
		//Initialize some global variables.
		message("UCN Core library initialized.");
		return true;
	}
}
