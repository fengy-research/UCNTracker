using GLib;
using Math;

using UCNTracker.Geometry;
using UCNTracker.Device;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
public class Experiment: Object, Buildable {
	public List<Part> parts;
	public List<Run> runs;
	public void add_child(Builder builder, GLib.Object child, string? type) {
		if(child is Part) {
			parts.prepend(child as Part);
		}
	}
	public signal void prepare(Run run);
	public signal void finish(Run run);
	public void run() {
		Run run = new Run(this);
		runs.prepend(run);
		prepare(run);
		run.run();
		finish(run);
	}
	public bool locate(Vertex vertex, out unowned Part located, out unowned Volume volume) {
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
