using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Geometry {
	public abstract class Surface {
		public Vector center;

		public abstract double sfunc(Vector point);
	}

	public class Tube:Surface {
		public Vector direction;
		public double radius;

		public Tube(Vector direction, Vector center, double radius) {
			this.direction = direction;
			this.center = center;
			this.radius = radius;
		}

		public override double sfunc(Vector point) {
			Vector v = point;
			v.x -= center.x;
			v.y -= center.y;
			v.z -= center.z;
			double proj = v.dot(direction);
			return sqrt(v.norm2() - proj * proj) - radius;
		}
	}

	public class Plane:Surface {
		public Vector norm;

		public Plane(Vector norm, Vector center) {
			this.norm = norm;
			this.center = center;
		}

		public override double sfunc(Vector point) {
			Vector p = point;
			p.x -= center.x;
			p.y -= center.y;
			p.z -= center.z;
			return norm.dot(p);
		}
	}
}
}
