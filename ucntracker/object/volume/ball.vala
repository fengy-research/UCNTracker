[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/***
	 * Although the Ball is also a Primitive,
	 * it doesn't make use of the surfaces[] array.
	 *****/
	public class Ball : Primitive {
		private double _radius;
		private Sphere sphere = new Sphere();

		public double radius {
			get { return sphere.radius; }
			set { sphere.radius = value; bounding_radius = value;}
		}
		construct {
			surfaces = {sphere};
		}
	}
}
