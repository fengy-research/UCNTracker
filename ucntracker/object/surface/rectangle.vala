[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Rectangle: Surface {
		public double width {get; set;}
		public double height {get; set;}

		public Rectangle.rotated(EulerAngles e) {
			(this as Surface).rotation = e;
		}
		public override double body_sfunc(Vector p) {
			return p.z;
		}
		public override bool body_is_in_region(Vector p) {
			double u2 = p.x * 2.0;
			double v2 = p.y * 2.0;
			if( u2 >= - width && u2 <= width &&
				v2 >= - height && v2 <= height) {
				return true;
			}
			return false;
		}
	}
}
