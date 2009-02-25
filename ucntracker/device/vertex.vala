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
		public Vertex copy () {
			Vertex rt = new Vertex();
			rt.position = position;
			rt.velocity = velocity;
			rt.weight = weight;
			return rt;
		}
	}
}
}
