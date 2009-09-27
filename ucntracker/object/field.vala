[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public abstract class Field: Object, GLib.YAML.Buildable {
		public List<Volume> volumes;

		private static const string[] tags = {"volumes"};
		private static Type[] types= {typeof(Volume)};

		static construct {
			GLib.YAML.Buildable.register_type(typeof(Field), tags, types);
		}

		public void add_child(GLib.YAML.Builder builder, GLib.Object child, string? type) throws Error {
			if(child is Volume) {
				volumes.prepend(child as Volume);
			} else {
				critical("expecting type %s for a child but found type %s",
					typeof(Volume).name(),
					child.get_type().name());
			}
			//base.add_child(builder, child, type);
		}
		/**
		 * Calculates the momentum P of the generalized position Q.
		 *
		 * @param track
		 *        the track of the particle, which contains the mass and 
		 *        physical property of the particle;
		 * @param Q
		 *        the current position of the particle in the phase space;
		 * @param P
		 *        the accumulated momentum of the particle in the phase 
		 *        space, do not reset the param;
		 *
		 * @return true if
		 *         fieldfunc has been calculated;
		 *         false if
		 *         fieldfunc has not been calculated.
		 **/
		public abstract bool fieldfunc(Track track, Vertex Q, Vertex P);

		public bool locate(Vector point, out unowned Volume child) {
			if(volumes == null) return true;
			foreach(Volume volume in volumes) {
				Sense sense = volume.sense(point);
				if(sense == Sense.IN) {
					child = volume;
					return true;
				}
			}
			child = null;
			return false;
		}
	}
}
