using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Device {
	[ModuleInit]
	public bool init(TypeModule module) {
		//Initialize some global variables.
		return true;
	}
}
}
