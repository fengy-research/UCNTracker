using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Vertex {
		public Vector position;
		public Vector velocity;
		public double weight;
		public double timestamp;
		public weak Part part;
		public weak Volume volume;

		public Vertex clone() {
			Vertex rt = new Vertex();
			rt.position = position;
			rt.velocity = velocity;
			rt.weight = weight;
			rt.timestamp = timestamp;
			rt.part = part;
			rt.volume = volume;
			return rt;
		}
		public void locate_in(Experiment experiment) {
			experiment.locate(this, out part, out volume);
		}
		public double[] to_array() {
			double[] y = new double[7];
			y[0] = position.x;
			y[1] = position.y;
			y[2] = position.z;
			y[3] = velocity.x;
			y[4] = velocity.y;
			y[5] = velocity.z;
			y[6] = timestamp;
			return y;
		}
		public void from_array(double[] y) {
			position.x = y[0];
			position.y = y[1];
			position.z = y[2];
			velocity.x = y[3];
			velocity.y = y[4];
			velocity.z = y[5];
			timestamp = y[6];
		}
	}
}
