[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public enum Sense {
		/**
		 * Sense is defined to describe the relative position relation
		 * between a point and a volume.
		 * -1 if inside
		 * 0 if on(very close) the surface
		 * +1 if outside
		 */
		IN = -1,
		ON = 0,
		OUT = 1
	}
	public abstract class Volume: Object, GLib.YAML.Buildable {
		private Gsl.RNG rng = new Gsl.RNG(Gsl.RNGTypes.mt19937);
		private const double delta = 1.0e-5; /* Used by grad*/
		public const double thickness = 1e-6; /* Used by sense and intersect*/
		private Vector _center = Vector(0.0, 0.0, 0.0);
		private EulerAngles _rotation = EulerAngles(0.0, 0.0, 0.0);
		public double bounding_radius { get; protected set; }

		public Vector center {
			get {
				return _center;
			}
			set {
				_center = value;
			}
		}

		public EulerAngles rotation {
			get {
				return _rotation;
			}
			set {
				_rotation = value;
			}
		}

		/**
		 * generate a point in the volume or on the surface.
		 *
		 * open: if true, treat the volume as an open one,
		 *        so that the surface is not sampled.
		 */
		public virtual Vector sample(bool open) {
			double x, y, z;
			double r;
			/* workaround bug 574352 */
			Vector point = Vector(0.0, 0.0, 0.0);
			Sense s = Sense.OUT;
			do{
				Gsl.Randist.dir_3d( rng, out x, out y, out z);
				r = rng.uniform();
				r = Math.cbrt(r) * bounding_radius;
				point = Vector(x * r, y * r, z * r);
				body_to_world(point);
				s = sense(point);
			} while(s == Sense.OUT || (open && s == Sense.ON));
			return point;
		}

		/**
		 * find the intersection on the surface of the volume
		 * with the straight line from point_in to point_out.
		 * the default implementaion looks for the intersection
		 * with brent solver from gsl.
		 *
		 * point_in: starting point of the line. 
		 * 			NOT neccesary inside the volume
		 * point_out: end point of the line.
		 * 			NOT neccesary outside the volume
		 *
		 * t: (0-1), the distances between the intersection and point_in,
		 *    normalized to the distance between point_out and pointer_in
		 *
		 * Returns: false if no intersection is found.
		 */

		public virtual bool intersect(CurveFunc curve, int direction,
			   double s_min, double s_max, out double s) {
			return Intersector.solve(this, curve, direction, s_min, s_max, out s);
		
		}

		/**
		 * return the sense of the point.
		 * - for inside;
		 * + for outside;
		 * 0 for on surface;
		 */
		public virtual Sense sense(Vector point) {
			if(point.distance(_center) > bounding_radius + thickness) {
				/* if the point is out of the bounding ball,
				 * don't bother calling sfunc and do the rotation
				 * */
				return Sense.OUT;
			}
			double s = sfunc(point);
			//if(fabs(s) < thickness) return Sense.ON;
			if(s < 0.0) return Sense.IN;
			if(s == 0.0) return Sense.ON;
			return Sense.OUT;
		}

		/**
		 * return an estimated 'signed' distance between a point
		 * and the surface of the volume.
		 * The sign of the distance follows the Sense convention.
		 *
		 * The estimation is accurate only when the point
		 * is close to the surface.
		 *
		 * This function takes the world coordinate as input,
		 * AKA world_to_body is not called.
		 *
		 */
		public virtual double sfunc(Vector point) {
			return body_sfunc(world_to_body(point));
		}

		/**
		 * return an estimated 'signed' distance between a point
		 * and the surface of the volume.
		 * The sign of the distance follows the Sense convention.
		 *
		 * This function takes the body coordinate as input. AKA,
		 * world_to_body is called.
		 */

		public abstract double body_sfunc(Vector point);

		/**
		 * return the gradient of the sfunc.
		 * When the point is close to the surface, this 
		 * becomes the normal direction at the given point,
		 * pointing outward.
		 *
		 * The default implementation returns a numerical
		 * result calculated from sfunc.
		 */
		public virtual Vector grad(Vector point) {
			Vector grad = Vector(0.0, 0.0, 0.0);
			Vector px0 = point;
			Vector py0 = point;
			Vector pz0 = point;
			Vector px1 = point;
			Vector py1 = point;
			Vector pz1 = point;
			px1.x += delta;
			py1.y += delta;
			pz1.z += delta;
			px0.x -= delta;
			py0.y -= delta;
			pz0.z -= delta;
			double delta2 = delta * 2.0;
			grad.x = (sfunc(px1) - sfunc(px0)) / delta2;
			grad.y = (sfunc(py1) - sfunc(py0)) / delta2;
			grad.z = (sfunc(pz1) - sfunc(pz0)) / delta2;
			double norm = grad.norm();
			if(norm != 0.0) {
				grad.x /= norm;
				grad.y /= norm;
				grad.z /= norm;
			} else {
				grad.x = 0.0;
				grad.y = 0.0;
				grad.z = 1.0;
			}
			return grad;
		}

		private Vector world_to_body(Vector point) {
			Vector rt = point;
			rt.translate_i(center);
			rt.rotate_i(rotation);
			return rt;
		}

		private Vector body_to_world(Vector point) {
			Vector rt = point;
			rt.rotate(rotation);
			rt.translate(center);
			return rt;
		}
	}
}
