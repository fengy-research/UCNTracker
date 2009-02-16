using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
public abstract class Volume: Object, Buildable {
	const double delta = 1.0e-3; /* Used by grad*/
	const double thickness = 1e-6; /*usaed by sense*/
	private Vector _center = Vector(0.0, 0.0, 0.0);
	private EulerAngles _rotation = EulerAngles(0.0, 0.0, 0.0);
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
	public abstract void sample(out Vector point, bool open);

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
		double length = point_in.distance(point_out);
		Vector direction = Vector((point_out.x - point_in.x)/length,
				(point_out.y - point_in.y)/length,
				(point_out.z - point_in.z)/length);

		solver_params params = {null};
		/* workaround vala bz 572079*/
		params.volume = this;
		params.length = length;
		params.point_in = &point_in;
		params.direction = &direction;
		params.value = 0.0;

		bool converged = false;
		int iter = 0;
		int max_iter = 100;
		Gsl.Function f = {intersect_solver_function, &params};
		Gsl.RootFsolver s = new Gsl.RootFsolver(Gsl.RootFsolverTypes.brent);
		s.set (&f, 0.0, 1.0);
		int status = Gsl.Status.CONTINUE;
		do {
			iter ++;
			s.iterate();
			status = Gsl.RootTest.residual(params.value, thickness);
			if(status == Gsl.Status.SUCCESS) {
				converged = true;
				break;
			}
		} while(status == Gsl.Status.CONTINUE && iter < max_iter);
		double t = s.root;
		intersection = Vector(
				point_in.x + direction.x * t * length,
				point_in.y + direction.y * t * length,
				point_in.z + direction.z * t * length);
				
		return converged;
	
	}

	/**
	 * sample a point on the surface.
	 */
	public abstract void sample_surface(out Vector point);

	/**
	 * return the sense of the point.
	 */
	public virtual Sense sense(Vector point) {
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
		Vector px = point.clone();
		Vector py = point.clone();
		Vector pz = point.clone();
		double center = sfunc(point);
		px.x += delta;
		py.y += delta;
		pz.z += delta;
		grad.x = (sfunc(px) - center) / delta;
		grad.y = (sfunc(py) - center) / delta;
		grad.z = (sfunc(pz) - center) / delta;
	}

	public void world_to_body(ref Vector point) {
		point.translate_i(center);
		point.rotate_i(rotation);
	}
	public void body_to_world(ref Vector point) {
		point.rotate(rotation);
		point.translate(center);
	}
	private struct solver_params {
		public unowned Volume volume;
		public double length;
		public Vector* point_in;
		public Vector* direction;
		public double value;
	}
	private static double intersect_solver_function (double t, solver_params* params) {
		Vector point = Vector(
				params->point_in->x + params->direction->x * t * params->length,
				params->point_in->y + params->direction->y * t * params->length,
				params->point_in->z + params->direction->z * t * params->length);
		assert(params->volume != null);
		double rt = params->volume.sfunc(point);
		return rt;
	}
}
}
