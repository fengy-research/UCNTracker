using GLib;
using Math;

using UCNTracker.Geometry;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Device {
	public class Part: Object, Buildable {
		public List<Volume> volumes;
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
		 */
		public signal void transport(Track track, Part? next, Vertex v_leave, Vertex v_enter);
		public signal void hit(Track track, Vertex vertex);

		private MeanFreePathFunc _mean_free_path_func = _default_mean_free_path_func;
		private string _mean_free_path_func_name = null;
		public string mean_free_path_func {
			get { return _mean_free_path_func_name; }
			set { _mean_free_path_func_name = value;
				Module module = Module.open(null, 0);
				void * pointer = null;
				if(!module.symbol(value, out pointer)) {
					_mean_free_path_func = _default_mean_free_path_func;
					critical("_mean_free_path_func: %s not found, use the default one", value);
				} else {
					_mean_free_path_func = (MeanFreePathFunc) pointer;
				}
			}
		}

		public double mean_free_path(Vertex vertex) {
			double mfp = _mean_free_path_func(this, vertex);
			assert(mfp > 0.0);
			return mfp;
		}
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
		public double default_mean_free_path {get; set; default = 1.0;}

		public static delegate double MeanFreePathFunc(Part part, Vertex vertex);
		public static double _default_mean_free_path_func(Part part, Vertex vertex) {
			return part._default_mean_free_path;
		}
	}
}
}
