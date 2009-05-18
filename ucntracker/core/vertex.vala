[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public abstract class Vertex {
		public Vector position;
		public Vector velocity;

		public double weight;
		public double timestamp;
		public weak Part part;
		public weak Volume volume;

		public virtual void copy_to(Vertex target) {
			target.position = position;
			target.velocity = velocity;
			target.weight = weight;
			target.timestamp = timestamp;
			target.part= part;
			target.volume = volume;
		}
		public virtual void to_array([CCode (array_length=false)]double [] y) {
			y[0] = position.x;
			y[1] = position.y;
			y[2] = position.z;
			y[3] = velocity.x;
			y[4] = velocity.y;
			y[5] = velocity.z;
		}
		public virtual void from_array([CCode (array_length = false)]double[] y) {
			position.x = y[0];
			position.y = y[1];
			position.z = y[2];
			velocity.x = y[3];
			velocity.y = y[4];
			velocity.z = y[5];
		}
	}
}
