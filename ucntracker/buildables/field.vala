[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public abstract class Field: Object, GLib.YAML.Buildable {
		public List<Volume> volumes;
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
		public abstract bool fieldfunc(Track track, Vertex v_in, Vertex v_out);

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
