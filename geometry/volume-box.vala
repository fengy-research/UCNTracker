using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Box : Convex, Buildable {
		private Vector _size = Vector (0.0, 0.0, 0.0);
		const int TOP = 0;
		const int BOTTOM = 1;
		const int LEFT = 2;
		const int RIGHT = 3;
		const int FRONT = 4;
		const int BACK = 5;

		public Vector size {get {return _size;} 
			set {
			_size = value;
			bounding_radius = _size.norm() / 2.0;
			message("_size = %lf %lf %lf", _size.x, _size.y, _size.z);
			message("bounding_radius = %lf", bounding_radius);
			surfaces[TOP].center.z = _size.z /2.0;
			surfaces[BOTTOM].center.z = - _size.z /2.0;
			surfaces[LEFT].center.y = - _size.y /2.0;
			surfaces[RIGHT].center.y = _size.y /2.0;
			surfaces[FRONT].center.x = _size.x /2.0;
			surfaces[BACK].center.x = - _size.x /2.0;
			}
		}
		construct {
			surfaces =  {
			new Plane(Vector(0.0, 0.0, 1.0), Vector(0.0, 0.0, 0.0)),
			new Plane(Vector(0.0, 0.0, -1.0), Vector(0.0, 0.0, 0.0)),
			new Plane(Vector(0.0, -1.0, 0.0), Vector(0.0, 0.0, 0.0)),
			new Plane(Vector(0.0, 1.0, 0.0), Vector(0.0, 0.0, 0.0)),
			new Plane(Vector(1.0, 0.0, 0.0), Vector(0.0, 0.0, 0.0)),
			new Plane(Vector(-1.0, 0.0, 0.0), Vector(0.0, 0.0, 0.0))
			};
		}
		public Box(Vector size) {
			this.size = size;
		}
	}
}
