[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
public class Experiment: Object, Buildable {
	public List<Part> parts;
	public List<Field> fields;
	public List<Run> runs;
	public MainContext context = null;
	public MainLoop loop = null;

	public double max_time_step {get; set; default=0.01;}

	public void add_child(Builder builder, GLib.Object child, string? type) throws Error {
		if(child is Part) {
			parts.insert_sorted(child as Part,
			      (CompareFunc) Part.layer_compare_func);
		}
		if(child is Field) {
			fields.prepend(child as Field);
		}
		//(base as Buildable).add_child(builder, child, type);
	}

	public signal void prepare(Run run);
	public signal void finish(Run run);
	public Run add_run() {
		Run run = new Run(this);
		runs.prepend(run);
		prepare(run);
		return run;
	}
	public void attach_run(Run run) {
		/*The run detaches itself by returning false in Run.run1,
		 * when it finishes.*/
		run.attach(this.context);
	}
	public void run() {
		loop = new MainLoop(this.context, false);
		Run run = add_run();
		attach_run(run);
		finish += quit;
		loop.run();
		finish -= quit;
	}
	public void quit() {
		loop.quit();
	}
	public bool locate(Vector point,
	       out unowned Part located, out unowned Volume volume) {
		foreach(Part part in parts) {
			if(part.locate(point, out volume)) {
				located = part;
				return true;
			}
		}
		located = null;
		return false;
	}
	public void QdQ(Track track, Vertex Q, 
	                         /*out */Vertex dQ) {
		dQ.position = Q.velocity;
		dQ.velocity = Vector(0.0, 0.0, 0.0);
		foreach(Field field in fields) {
			field.fieldfunc(track, Q, dQ);
		}
	}
}}
