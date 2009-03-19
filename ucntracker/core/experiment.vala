using GLib;
using Math;

using UCNTracker.Geometry;
using UCNTracker.Device;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
public class Experiment: Object, Buildable {
	public List<Part> parts;
	public List<Run> runs;
	public MainContext context = null;
	public MainLoop loop = null;

	public void add_child(Builder builder, GLib.Object child, string? type) {
		if(child is Part) {
			parts.insert_sorted(child as Part,
			      (CompareFunc) Part.layer_compare_func);
			message("add_child");
		}
	}

	public signal void prepare(Run run);
	public signal void finish(Run run);
	public Run add_run() {
		Run run = new Run(this);
		runs.prepend(run);
		return run;
	}
	public void attach_run(Run run) {
		/*The run detaches itself by returning false in Run.run1,
		 * when it finishes.*/
		run.source.attach(this.context);
	}
	public void run() {
		loop = new MainLoop(this.context, false);
		Run run = add_run();
		loop.run();
	}
	public void quit() {
		loop.quit();
	}
	public bool locate(Vertex vertex,
	       out unowned Part located, out unowned Volume volume) {
		foreach(Part part in parts) {
			if(part.locate(vertex, out volume)) {
				located = part;
				return true;
			}
		}
		located = null;
		return false;
	}
}}
