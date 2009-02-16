using GLib;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
public enum Sense {
	/**
	 * Sense is defined to describe the relative position relation
	 * between a point and a volume.
	 * -1 if inside
	 * 0 if on(very close) the surface
	 * +1 if outside
	 */
	IN = -1,
	ON = 0,
	OUT = 1
}
}
