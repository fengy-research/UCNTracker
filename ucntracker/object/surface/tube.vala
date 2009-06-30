[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Tube: Surface {
		public double radius {get; set;}

		public double length {get; set;}
		/**
		 * The starting of the arc,
		 * in degrees, from 0 to 360.
		 */
		public double arc_start {get; set; default = 0.0;}
		/**
		 * The ending of the arc,
		 *
		 * in degrees, from 0, to 360.
		 */
		public double arc_end {get; set; default = 360.0;}

		public Tube.rotated(EulerAngles e) {
			(this as Surface).rotation = e;
		}

		public override double body_sfunc(Vector p) {
			double w = (Math.sqrt(p.x * p.x + p.y * p.y) - radius);
			return w;
		}

		public override bool body_is_in_region(Vector p) {
			double u = Math.atan2(p.y, p.x)/ Math.PI * 180.0 + 180.0;
			double v = p.z;
			if(u  >= arc_start && u <= arc_end 
			&& v >= 0 && v <= length ) {
				return true;
			}
			return false;
		}
	}

}
