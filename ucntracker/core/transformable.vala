[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/**
	 * A Transformable can be either a Volume or a Surface
	 *
	 * A geometryic shape in UCNTracker is actually a transformable.
	 * AKA, it can be applied by a shift, specified by the new vector of
	 * the center, and then applied by a rotation, specified by a set of 
	 * Euler Angles.
	 *
	 * */
	public abstract class Transformable: Object {
		private const double delta = 1.0e-5; /* Used by grad*/

		public Vector center {get; set; }

		public EulerAngles rotation { get; set; }
		
		construct {
			rotation = EulerAngles(0.0, 0.0, 0.0);
			center = Vector(0.0, 0.0, 0.0);
		}
		public Vector world_to_body(Vector point) {
			Vector rt = point;
			rt.translate_i(center);
			rt.rotate_i(rotation);
			return rt;
		}

		public Vector body_to_world(Vector point) {
			Vector rt = point;
			rt.rotate(rotation);
			rt.translate(center);
			return rt;
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
		public virtual Vector normal(Vector point) {
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
		
	}
}
