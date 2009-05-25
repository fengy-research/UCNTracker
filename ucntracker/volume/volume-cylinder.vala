[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Cylinder : Primitive {
		private double _length = 0.0;
		private double _radius = 0.0;

		public Circle top = new Circle.rotated(EulerAngles(0, 0, 0));
		public Circle bottom = new Circle.rotated(EulerAngles(0, 180, 0));

		public Tube tube = new Tube();

		public double length {
			get { return tube.length; }
			set {
				tube.length = value;
				bounding_radius =
				  Math.sqrt(value * value + tube.radius* tube.radius);
				top.center = Vector(0, 0, value);
			}
		}

		public double radius {
			get { return tube.radius; }
			set {
				tube.radius= value;
				bounding_radius =
				  Math.sqrt(tube.length * tube.length + tube.radius * tube.radius);
				tube.radius = radius;
				top.radius = radius;
				bottom.radius = radius;
			}
		}

		construct {
			surfaces = {top, bottom, tube};
		}
		public Cylinder(double length, double radius) {
			this.length = length;
			this.radius = radius;
		}
	}
}
