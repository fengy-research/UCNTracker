[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public abstract class Vertex {
		/* Accounting */
		public weak Part part;
		public weak Volume volume;
		public double timestamp;
		public double weight;

		/* Phasespace parameters */
		public Vector position;
		public Vector velocity;
		public double spin_precession;
		public double spin_parallel;

		public virtual void reset() {
			position = Vector(0, 0, 0);
			velocity = Vector(0, 0, 0);
			spin_precession = 0;
			spin_parallel = 0;
		}

		public virtual void copy_to(Vertex target) {
			target.position = position;
			target.velocity = velocity;
			target.spin_precession = spin_precession;
			target.spin_parallel = spin_parallel;
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
			y[6] = spin_precession;
			y[7] = spin_parallel;
		}
		public virtual string to_string() {
			return "t=%lf w= %lf(%s) v=(%s) s=%lf Sz=%lf in %s.%s".printf(
						timestamp, 
						weight,
						position.to_string(), 
						velocity.to_string(),
						spin_precession,
						spin_parallel,
						part!=null?part.get_name():"#nopart#",
						volume!=null?volume.get_name():"#novolume#");
		}
		public double get_sfunc_value() {
			if(volume != null) {
				return volume.sfunc(position);
			}
			return double.NAN;
		}
		public virtual void from_array([CCode (array_length = false)]double[] y) {
			position.x = y[0];
			position.y = y[1];
			position.z = y[2];
			velocity.x = y[3];
			velocity.y = y[4];
			velocity.z = y[5];
			spin_precession = y[6];
			spin_parallel = y[7];
		}
	}
}
