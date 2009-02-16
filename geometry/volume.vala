using GLib;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
public abstract class Volume: Object/*, Buildable*/ {
	public Vector center {
		get; set;
	}
	public Vector zoom {
		get; set;
	}
	public EulerAngles rotation {
		get; set;
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
	 *
	 * @point_in: starting point of the line. 
	 * 			NOT neccesary inside the volume
	 * @point_out: end point of the line.
	 * 			NOT neccesary outside the volume
	 *
	 * Returns: false if no intersection is found.
	 */

	public abstract bool intersect(Vector point_in, Vector point_out,
		   out Vector intersection);	

	/**
	 * sample a point on the surface.
	 */
	public abstract void sample_surface(out Vector point);

	/**
	 * return the sense of the point.
	 */
	public abstract Sense sense(Vector point);

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
	 */

	public abstract void grad(Vector point, out Vector grad);

}
}
