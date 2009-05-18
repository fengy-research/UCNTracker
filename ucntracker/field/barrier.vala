[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class BarrierField: Field {
		public Vector direction { get; set;}
		public Vector center {get; set;}
		public double factor {get; set; default = 1.0;}
		double[] field_Bs = new double[0];
		double[] field_xs = new double[0];
		public string map {set {
			string[] lines = value.split("\n");
			field_Bs = new double[lines.length];
			field_xs = new double[lines.length];
			int i = 0;
			foreach(unowned string line in lines) {
				string[] words = line.split(",");
				assert(words.length == 2);
				double x = words[0].to_double();
				double B = words[1].to_double();
				field_xs[i] = x;
				field_Bs[i] = B;
				i++;
			}
		}
		}

		public override void fieldfunc(Track track, Vertex Q, 
		               Vertex dQ) {
			/* FIXME: the rotation is not used.
			 * Perhaps Part and Field should derive from a class
			 * which has no center, neither be it a volume
			 * */
			Vector pos = Q.position;
			pos.translate_i(center);
			double x = pos.dot(direction);

			if(x < field_xs[0]) return;

			for(int i = 0; i < field_xs.length - 1; i++) {
				double x0 = field_xs[i];
				double x1 = field_xs[i+1];
				double y0 = field_Bs[i];
				double y1 = field_Bs[i+1];
				if(x >= x0 && x < x1) {
					double dx = track.magnetic_helicity * factor * track.mdm * ((y1 - y0))/((x1 - x0) ) / track.mass;
					dQ.velocity.x += direction.x * dx;
					dQ.velocity.y += direction.y * dx;
					dQ.velocity.z += direction.z * dx;
//					message("magnetic effect : slope= %lg mdm=%lg [%d] %lg", (y1- y0)/(x1-x0), track.mdm, i, dx);
					return;
				}
			}
			return;
		}
	}
}
