[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Sphere :Surface {
		public double radius {get; set;}
		public override double body_sfunc(Vector p) {
			return p.norm() - radius;
		}
		public override bool body_is_in_region(Vector p) {
			return true;
		}
	}
}
