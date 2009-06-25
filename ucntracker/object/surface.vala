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

}
