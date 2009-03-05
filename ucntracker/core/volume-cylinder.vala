using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Geometry {
	public class Cylinder : Convex, Buildable {
		private double _length = 0.0;
		private double _radius = 0.0;
		const int LEFT = 0;
		const int RIGHT = 1;
		const int TUBE = 2;

		public double length {
			get { return _length; }
			set {
				_length = value;
				bounding_radius =
				  sqrt(_length * _length / 4.0 + _radius * _radius);
				surfaces[LEFT].center.x = - _length / 2.0;
				surfaces[RIGHT].center.x = _length / 2.0;
			}
		}

		public double radius {
			get { return _radius; }
			set {
				_radius= value;
				bounding_radius =
				  sqrt(_length * _length / 4.0 + _radius * _radius);
				(surfaces[TUBE] as Tube).radius = _radius;
			}
		}

		construct {
			surfaces = {
				new Plane(Vector(-1.0, 0.0, 0.0), Vector(0.0, 0.0, 0.0)),
				new Plane(Vector(1.0, 0.0, 0.0), Vector(0.0, 0.0, 0.0)),
				new Tube(Vector(1.0, 0.0, 0.0), Vector(0.0, 0.0, 0.0), 0.0)
			};
		}

		public Cylinder(double length, double radius) {
			this.length = length;
			this.radius = radius;
		}
	}
}
}
