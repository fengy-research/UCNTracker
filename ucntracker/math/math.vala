[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	[CCode (cname = "ucn_math_init")]
	[ModuleInit]
	public bool math_init(TypeModule module) {
		//Initialize some global variables.
		message("UCN Math library initialized.");
		return true;
	}
}
