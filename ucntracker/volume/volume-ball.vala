[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/***
	 * Although the Ball is also a Primitive,
	 * it doesn't make use of the surfaces[] array.
	 *****/
	public class Ball : Primitive , Buildable {
		private double _radius;
		public double radius {
			get { return _radius; }
			set { _radius = value; bounding_radius = value;}
		}

		public override double sfunc(Vector point) {
			return point.distance(center) - radius;
		}	
	}
}
