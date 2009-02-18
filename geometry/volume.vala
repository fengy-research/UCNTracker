using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
public abstract class Volume: Object, Buildable {
	private Gsl.RNG rng = new Gsl.RNG(Gsl.RNGTypes.mt19937);
	private const double delta = 1.0e-3; /* Used by grad*/
	public const double thickness = 1e-6; /* Used by sense and intersect*/
	private Vector _center = Vector(0.0, 0.0, 0.0);
	private EulerAngles _rotation = EulerAngles(0.0, 0.0, 0.0);
	public abstract double radius { get; }
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
	 * @open: if true, treat the volume as an open one,
	 *        so that the surface is not sampled.
	 */
	public virtual void sample(out Vector point, bool open) {
		double x, y, z;
		double r;
		Sense s = Sense.OUT;
		Gsl.Randist.dir_3d( rng, out x, out y, out z);
		r = rng.uniform();
		r = sqrt(r) * 3.0;
		do{
			point = Vector(x * r, y * r, z * r);
			body_to_world(ref point);
			s = sense(point);
		} while(s == Sense.OUT || (open && s == Sense.ON));
	}

	/**
	 * find the intersection on the surface of the volume
	 * with the straight line from point_in to point_out.
	 * the default implementaion looks for the intersection
	 * with brent solver from gsl.
	 *
	 * @point_in: starting point of the line. 
	 * 			NOT neccesary inside the volume
	 * @point_out: end point of the line.
	 * 			NOT neccesary outside the volume
	 * Returns: false if no intersection is found.
	 */

	public virtual bool intersect(Vector point_in, Vector point_out,
		   out Vector intersection) {
		return Intersection.solve(this, point_in, point_out, out intersection);
	
	}

	/**
	 * return the sense of the point.
	 */
	public virtual Sense sense(Vector point) {
		if(point.distance(_center) > radius + thickness) {
			/* if the point is out of the bounding ball,
			 * don't bother calling sfunc and do the rotation
			 * */
			return Sense.OUT;
		}
		double s = sfunc(point);
		if(fabs(s) < thickness) return Sense.ON;
		if(s < 0.0) return Sense.IN;
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
	 */
	public abstract double sfunc(Vector point);

	/**
	 * return the gradient of the sfunc.
	 * When the point is close to the surface, this 
	 * becomes the normal direction at the given point,
	 * pointing outward.
	 *
	 * The default implementation returns a numerical
	 * result calculated from sfunc.
	 */
	public virtual void grad(Vector point, out Vector grad) {
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
	}

	public void world_to_body(ref Vector point) {
		point.translate_i(center);
		point.rotate_i(rotation);
	}
	public void body_to_world(ref Vector point) {
		point.rotate(rotation);
		point.translate(center);
	}
}
}
