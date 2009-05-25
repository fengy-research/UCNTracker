[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/****
	 * This is to work around VALA bz 572920
	 */
	public static Surface ____load_surface_headers___;
	public abstract class Primitive : Volume {
		protected Surface[] surfaces = null;

		public override double body_sfunc(Vector p) {
			double max = -double.MAX;
			double inside_max = -double.MAX;
			bool in_side = true;
			foreach(Surface surface in surfaces) {
				Vector uvw = surface.xyz_to_uvw(p);
				/* if the point is on some of the surfaces, 
				 * we still want to return the max sfunc,
				 * instead of a very negative value */
				in_side &= (uvw.z <= 0.0);
				if( uvw.z <= 0.0) {
					if(uvw.z > inside_max ) inside_max = uvw.z;
				}
				if(uvw.z > max ) max = uvw.z;
			}
			return in_side?inside_max:max;
		}

	}
}
