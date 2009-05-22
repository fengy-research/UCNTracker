[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Cylinder : Primitive {
		private double _length = 0.0;
		private double _radius = 0.0;
		const int TOP = 0;
		const int BOTTOM = 1;
		const int TUBE = 2;

		public double length {
			get { return _length; }
			set {
				_length = value;
				bounding_radius =
				  Math.sqrt(_length * _length + _radius * _radius);
				surfaces[BOTTOM].center.z = 0;
				surfaces[TOP].center.z = _length;
			}
		}

		public double radius {
			get { return _radius; }
			set {
				_radius= value;
				bounding_radius =
				  Math.sqrt(_length * _length + _radius * _radius);
				(surfaces[TUBE] as Tube).radius = _radius;
			}
		}

		construct {
			surfaces = {
				new Plane(Vector(0.0, 0.0, 1.0), Vector(0.0, 0.0, 0.0)),
				new Plane(Vector(0.0, 0.0, -1.0), Vector(0.0, 0.0, 0.0)),
				new Tube(Vector(0.0, 0.0, 1.0), Vector(0.0, 0.0, 0.0), 0.0)
			};
		}

		public Cylinder(double length, double radius) {
			this.length = length;
			this.radius = radius;
		}
	}
}
