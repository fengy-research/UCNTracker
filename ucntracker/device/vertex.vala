using GLib;
using Math;

using UCNTracker.Geometry;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Device {
	public class Vertex {
		public Vector position;
		public Vector velocity;
		public double weight;
	}
}
}
