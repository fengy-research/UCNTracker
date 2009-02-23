using GLib;
using Math;

using UCNTracker.Geometry;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Device {
	public class Part: Object, Buildable {
		public Volume volume;
		public void add_child(Builder builder, GLib.Object child, string? type) {
			switch(type) {
				case "volume":
					volume = child as Volume;
				break;
				default:
				assert_not_reached();
			}
		}
	}
}
}
