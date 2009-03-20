using GLib;
using Gtk;
using GL;
using GLU;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Renderer {
		public int layer;
		public void visit_union(Union union);
		public void visit_primitive(Primitive pri);
		public void visit_volume(Volume volume);
		public void visit_part(Part part);
		public void visit_experiment(Experiment);
	}
