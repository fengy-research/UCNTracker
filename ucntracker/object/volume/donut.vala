[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Donut : Primitive {
		private double _tube_radius= 0.0;
		private double _radius = 0.0;
		private Torus torus = new Torus();

		public double tube_radius {
			get { return torus.tube_radius;}
			set { torus.tube_radius = value; bounding_radius = torus.tube_radius + torus.radius;}
		}
		public double radius {
			get { return torus.radius;}
			set { torus.radius = value; bounding_radius = torus.tube_radius + torus.radius;}
		}

		construct {
			surfaces = {torus};
		}
	}
}
