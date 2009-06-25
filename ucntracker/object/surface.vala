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
	 * w = 0
	 *
	 * The effective region of the surface is defined by R(u, v) < 0
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
		public virtual bool is_in_region(Vector point) {
			return body_is_in_region(world_to_body(point));
		}
		public abstract bool body_is_in_region(Vector point);
		

		/**
		 * If the surface is visible in the visualization 
		 * */
		public bool visible {get; set; default = true;}
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

		public override double body_sfunc(Vector p) {
			return p.z;
		}
		public override bool body_is_in_region(Vector p) {
			double u = Math.atan2(p.y, p.x)/ Math.PI * 180.0 + 180.0;
			double v = Math.sqrt(p.x * p.x + p.y * p.y);
			if(v < radius && u >= arc_start && u <= arc_end) {
				return true;
			}
			return false;
		}
	}
	public class Rectangle: Surface {
		public double width {get; set;}
		public double height {get; set;}

		public Rectangle.rotated(EulerAngles e) {
			(this as Surface).rotation = e;
		}
		public override double body_sfunc(Vector p) {
			return p.z;
		}
		public override bool body_is_in_region(Vector p) {
			double u2 = p.x * 2.0;
			double v2 = p.y * 2.0;
			if( u2 >= - width && u2 <= width &&
				v2 >= - height && v2 <= height) {
				return true;
			}
			return false;
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

		public override double body_sfunc(Vector p) {
			double w = (Math.sqrt(p.x * p.x + p.y * p.y) - radius);
			return w;
		}

		public override bool body_is_in_region(Vector p) {
			double u = Math.atan2(p.y, p.x)/ Math.PI * 180.0 + 180.0;
			double v = p.z;
			if(u  >= arc_start && u <= arc_end 
			&& v >= 0 && v <= length ) {
				return true;
			}
			return false;
		}
	}
	public class Sphere :Surface {
		public double radius {get; set;}
		public override double body_sfunc(Vector p) {
			return p.norm() - radius;
		}
		public override bool body_is_in_region(Vector p) {
			return true;
		}
	}
	public class Torus :Surface {
		public double tube_radius {get; set;}
		public double radius { get; set;}

		public override double body_sfunc(Vector p) {
			double dn = Math.sqrt(p.x * p.x + p.y * p.y);
			double w = Math.sqrt((dn - radius)*(dn - radius) + p.z * p.z) - tube_radius;
			return  w;
		}
		
		public override bool body_is_in_region(Vector p) {
			return true;
		}
	}
}
