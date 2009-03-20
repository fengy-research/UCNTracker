using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/****
	 * This is to work around VALA bz 572920
	 */
	public static Surface ____load_surface_headers___;
	public abstract class Primitive : Volume {
		protected Surface[] surfaces = null;

		public override double sfunc(Vector point) {
			Vector p = point;	
			world_to_body(ref p);
			double max = -double.MAX;
			double inside_max = -double.MAX;
			double s;
			bool in_side = true;
			foreach(Surface surface in surfaces) {
				s = surface.sfunc(p);
				/* if the point is on some of the surfaces, 
				 * we still want to return the max sfunc,
				 * instead of a very negative value */
				in_side &= (s <= 0.0);
				if( s <= 0.0) {
					if(s > inside_max ) inside_max = s;
				}
				if(s > max ) max = s;
			}
			return in_side?inside_max:max;
		}

	}
}
