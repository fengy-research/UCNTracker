using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public struct EulerAngles {
		/***
		 * rotation from x y z -> X Y Z.
		 * intersection between xy and XY is the 'line of nodes'
		 * Refer to wikepedia: Euler_angles.
		 */
		public double alpha; // between x and the line of nodes. in degrees
		public double beta;  // between z and Z
		public double gamma; // between the line of nodes X
		/* q should be readonly*/
		public Quaternion q;

		public EulerAngles(double alpha, double beta, double gamma) {
			this.alpha = alpha;
			this.beta = beta;
			this.gamma = gamma;
			update_q();
		}

		[CCode (instance_pos = 2)]
		public bool parse(string foo) {
			string[] words = foo.split(" ");
			if(words == null || words.length != 3) 
				words = foo.split(",");
			if(words == null || words.length != 3) 
				return false;
			alpha = words[0].to_double();
			beta = words[1].to_double();
			gamma = words[2].to_double();
			update_q();
			return true;
		}

		/* update the quaternion */
		private void update_q() {
			q = Quaternion.from_rotation(Vector(0, 0, 1), alpha /180.0 * PI);
			q.mul(Quaternion.from_rotation(Vector(1, 0, 0), beta/ 180.0 * PI));
			q.mul(Quaternion.from_rotation(Vector(0, 0, 1), gamma/ 180.0 * PI));
			q.normalize();
		}
		public string to_string(string format="%lf %lf %lf") {
			return format.printf(alpha, beta, gamma);
		}
	}

}
