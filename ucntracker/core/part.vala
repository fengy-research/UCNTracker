using GLib;
using Math;
using Vala.Runtime;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Part: VolumeGroup{
		public int layer {get; set; default = 0;}
		public double potential {get; set; default = 1.0;}
		public double mfp {get; set; default = 1.0;}


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
		       Vertex s_leave, Vertex s_enter, bool* transported);

		[CCode (instance_pos = -1)]
		public void optic_reflect(Part p, Track track,
		       Vertex leave, Vertex enter, bool* transported) {
			Vector norm = track.tail.volume.grad(leave.position);
			message("norm = %s", norm.to_string());
			Vector reflected = leave.velocity.reflect(norm);
			message("reflection: %lf == %lf", leave.velocity.norm(), reflected.norm());
			leave.velocity = reflected;
			*transported = false;
		}

		public virtual signal void hit(Track track, Vertex next);

		public virtual double calculate_mfp(Vertex vertex) {
			return mfp;
		}

		public static int layer_compare_func(Part a, Part b) {
			return -(a.layer - b.layer);
		}
		
	}
}
