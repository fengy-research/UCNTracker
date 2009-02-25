using GLib;
using Math;

using UCNTracker.Geometry;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Device {
	public class Experiment: Object, Buildable {
		public List<Part> parts;
		public void add_child(Builder builder, GLib.Object child, string? type) {
			if(child is Part) {
				parts.prepend(child as Part);
			}
		}
	}
}}
