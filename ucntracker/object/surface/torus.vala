[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {

	public class Torus :Surface {
		public double tube_radius {get; set;}
		public double radius { get; set;}

		public override double body_sfunc(Vector p) {
			double dn = Math.sqrt(p.x * p.x + p.y * p.y);
			double w = Math.sqrt((dn - radius)*(dn - radius) + p.z * p.z) - tube_radius;
			return  w;
		}
		
		public override bool body_is_in_region(Vector p) {
			return true;
		}
	}
}
