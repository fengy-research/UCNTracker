[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/* Never intended to be created by a builder.
	 * Instantiated by Part and Field.
	 * */
	public abstract class VolumeGroup: Volume, Buildable {
		public List<Volume> volumes;
		public void add_child(Builder builder, GLib.Object child, string? type) {
			if(child is Volume) {
				message("adding child %s.", (child as Buildable).get_name());
				volumes.prepend(child as Volume);
			} else {
				critical("expecting type %s for a child but found type %s",
					typeof(Volume).name(),
					child.get_type().name());
			}
		}
		public override double sfunc(Vector point) {
			error("sfunc of a volume group is never called!");
			return 0.0;
		}

		public bool locate(Vector point, out unowned Volume child) {
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
