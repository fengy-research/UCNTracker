[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/**
	 * A Surface is a 2D object, which can affect the particle tracks by
	 * reflect, transport or diffuse.
	 *
	 * Mathamatically a Surface is defined as
	 * S(x, y, z) = 0
	 * T(x, y, z) < 0
	 *
	 * When S is close to 0,
	 * |S| is the distance from the given point to the surface.
	 *
	 * T(x, y, z) < 0 for inside the surface region,
	 * T(x, y, z) = 0 for the border of the surface  region
	 * T(x, y, z) > 0 for outside of the surface region
	 *
	 * For this special kind of 2D (regional) surfaces,
	 *
	 * the normal direction of the surface is given by grad F,
	 *
	 * A bisection method can be used to find the inner
	 * (closer to the starting point of the curve)
	 * and outer (further to the starting point) intersection between
	 * a given particle trajectory and the extended surface;
	 * Then S(u, v) can be deployed to
	 * test if the intersection is inside the surface region or not.
	 *
	 * To define the surface, we need two functions, S and T.
	 */
	public abstract class Surface{
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
			return Math.sqrt(v.norm2() - proj * proj) - radius;
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
