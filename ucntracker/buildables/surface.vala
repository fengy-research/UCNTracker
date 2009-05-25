[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/**
	 * A Surface is a 2D object, which can affect the particle tracks by
	 * reflect, transport or diffuse.
	 *
	 * Mathamatically a Surface is defined as
	 * x = x(u, v, w)
	 * y = y(u, v, w)
	 * z = z(u, v, w)
	 *
	 * where u = [-1, 1]
	 * v = [-1, 1]
	 * w = 0
	 *
	 * for points not on the surface, when w is small, 
	 * |w| is the distance from the given point to the surface.
	 *
	 * To make life easier we have a xyz_to_uvw function that takes 
	 * a body coordinate and covert it to the parametrization coordinate
	 * u v w
	 *
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
	public abstract class Surface : Transformable, GLib.YAML.Buildable {

		public virtual Vector xyz_to_uvw(Vector point) {
			return body_xyz_to_uvw(world_to_body(point));
		}
		public abstract Vector body_xyz_to_uvw(Vector point);
		public bool is_inside_uvw(Vector uvw) {
			if(uvw.x >= -1.0 && uvw.x <= 1.0 
			&& uvw.y >= -1.0 && uvw.y <= 1.0) {
				return true;
			}
			return false;
		}
	}

	public class Circle : Surface {
		public double radius {get; set;}
		/**
		 * The starting of the arc,
		 * in degrees, from 0 to 360.
		 */
		public double arc_start {get; set; default = 0.0;}
		/**
		 * The ending of the arc,
		 *
		 * in degrees, from 0, to 360.
		 */
		public double arc_end {get; set; default = 360.0;}

		public Circle.rotated(EulerAngles e) {
			(this as Surface).rotation = e;
		}

		public override Vector body_xyz_to_uvw(Vector p) {
			double w = p.z;
			double u = ((Math.atan2(p.y, p.x))/ Math.PI * 180.0 - arc_start)/(arc_end- arc_start) * 2.0;
			double v = 2.0 * Math.sqrt(p.x * p.x + p.y * p.y) / radius - 1.0;
			return Vector(u, v, w);
		}
	}
	public class Rectangle: Surface {
		public double width {get; set;}
		public double height {get; set;}

		public Rectangle.rotated(EulerAngles e) {
			(this as Surface).rotation = e;
		}
		public override Vector body_xyz_to_uvw(Vector p) {
			double w = p.z;
			double u = (p.x - width)/ width * 2.0;
			double v = (p.y - height) / height * 2.0;
			return Vector(u, v, w);
		}
	}

	public class Tube: Surface {
		public double radius {get; set;}

		public double length {get; set;}
		/**
		 * The starting of the arc,
		 * in degrees, from 0 to 360.
		 */
		public double arc_start {get; set; default = 0.0;}
		/**
		 * The ending of the arc,
		 *
		 * in degrees, from 0, to 360.
		 */
		public double arc_end {get; set; default = 360.0;}

		public Tube.rotated(EulerAngles e) {
			(this as Surface).rotation = e;
		}

		public override Vector body_xyz_to_uvw(Vector p) {
			double w = (Math.sqrt(p.x * p.x + p.y * p.y) - radius);
			double u = ((Math.atan2(p.y, p.x))/ Math.PI * 180.0 - arc_start)/(arc_end- arc_start) * 2.0;
			double v = (p.z - 0.5 * length ) / length;
			return Vector(u, v, w);
		}
	}
	public class Sphere :Surface {
		public double radius {get; set;}
		public override Vector body_xyz_to_uvw(Vector p) {
			double w = p.norm() - radius;
			/* This is tricky. 
			 * Because the Sphere is a closed surface that separates the space into two parts,
			 * and because we don't define a region of the sphere,
			 * We don't need to define u & v.
			 * */
			double u = 0.0;
			double v = 0.0;
			return Vector(u, v, w);
		}
	}
	public class Torus :Surface {
		public double tube_radius {get; set;}
		public double radius { get; set;}

		public override Vector body_xyz_to_uvw(Vector p) {
			double dn = Math.sqrt(p.x * p.x + p.y * p.y);
			double w = Math.sqrt((dn - radius)*(dn - radius) + p.z * p.z) - tube_radius;
			double u = 0.0;
			double v = 0.0;
			return Vector(u, v, w);
		}
		
	}
}
