using GLib;
using Math;
using Vala.Runtime;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Part: Object, Buildable {
		public List<Volume> volumes;
		public List<CrossSection> cross_sections;

		public int layer {get; set; default = 0;}
		public double potential {get; set; default = 1.0;}
		public double mfp_factor {get; set; default = 1.0;}

		public void add_child(Builder builder, GLib.Object child, string? type) {
			if(child is Volume) {
				message("adding child %s.", (child as Buildable).get_name());
				volumes.prepend(child as Volume);
			} else if (child is CrossSection) {
				cross_sections.prepend(child as CrossSection);
			} else {
				critical("expecting type %s/%s for a child but found type %s",
					typeof(Volume).name(),
					typeof(CrossSection).name(),
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
		 * NOTE: this syntax of ref bool depends on a local patch for
		 * Bug 574403
		 */
		public virtual signal void transport(Track track,
		       Vertex s_leave, Vertex s_enter, ref bool transported);

		public static int layer_compare_func(Part a, Part b) {
			return -(a.layer - b.layer);
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
