[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/****
	 * This is to work around VALA bz 572920
	 */
	public static Surface ____load_surface_headers___;
	public abstract class Primitive : Volume, GLib.YAML.Buildable {
		protected Surface[] surfaces = null;

		public override double body_sfunc(Vector p) {
			double max = -double.MAX;
			double inside_max = -double.MAX;
			bool in_side = true;
			foreach(Surface surface in surfaces) {
				double s = surface.sfunc(p);
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

		public Object? get_internal_child(GLib.YAML.Builder builder,
			string name) {
			for(int i = 0; surfaces!= null && i < surfaces.length;
				i++) {
				if(surfaces[i].get_name() == name) {
					return surfaces[i];
				}
			}
			return null;
		}
		protected void set_surface_names(string[] names) {
			assert(surfaces.length == names.length);
			for(int i = 0; surfaces!= null && i < surfaces.length;
				i++) {
				surfaces[i].set_name(names[i]);
			}
		}
	}
}
