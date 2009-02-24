using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Geometry {
	[ModuleInit]
	public bool init(TypeModule module) {
		//Initialize some global variables.
		message("Geometry initialized");
		return true;
	}
}
}
