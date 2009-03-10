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

		public Vertex clone() {
			Vertex rt = new Vertex();
			rt.position = position;
			rt.velocity = velocity;
			rt.weight = weight;
			return rt;
		}
		public double[] to_array() {
			double[] y = new double[6];
			y[0] = position.x;
			y[1] = position.y;
			y[2] = position.z;
			y[3] = velocity.x;
			y[4] = velocity.y;
			y[5] = velocity.z;
			return y;
		}
		public void from_array(double[] y) {
			position.x = y[0];
			position.y = y[1];
			position.z = y[2];
			velocity.x = y[3];
			velocity.y = y[4];
			velocity.z = y[5];
		}
	}
}
}
