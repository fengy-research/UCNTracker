using GLib;
using Math;

using UCNTracker.Geometry;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Device {
	public class Part: Object, Buildable {
		public List<Volume> volumes;
		public int layer {get; set; default = 0;}

		public void add_child(Builder builder, GLib.Object child, string? type) {
			if(child is Volume) {
				Volume volume = child as Volume;
				volumes.prepend(child as Volume);
			} else {
				critical("expecting type %s for a child but found type %s",
					typeof(Volume).name(),
					child.get_type().name());
			}
		}

		/**
		 * emitted when a track tries to go through a surface.
		 * next == null if the track is getting into the ambient.
		 *
		 * transported: whether the track successfully transports 
		 *   to the next part.
		 *
		 * if true, 
		 *   the track continues to the next part.
		 *   v_enter should be set to the vertex for the transported track
		 *
		 * if false, 
		 *   the track doesn't continue to the next part.
		 *   v_leave should be set to the new vertex for the reflected track.
		 *
		 * in either case, the handler can fork the track at the surface
		 * to produce the track for the other case.
		 *
		 * the pointer is to workaround vala bug 574403.
		 */
		public virtual signal void transport(Track track,
		       State s_leave, State s_enter, bool* transported);

		public virtual signal void hit(Track track, State next);

		public bool locate(Vertex vertex, out unowned Volume child) {
			foreach(Volume volume in volumes) {
				Sense sense = volume.sense(vertex.position);
				if(sense == Sense.IN) {
					child = volume;
					return true;
				}
			}
			child = null;
			return false;
		}

		public static int layer_compare_func(Part a, Part b) {
			return -(a.layer - b.layer);
		}
		
	}
}
}