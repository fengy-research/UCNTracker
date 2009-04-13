using UCNTracker;
using Vala.Runtime;

Builder builder;
Camera camera;
public int main(string[] args) {
	UCNTracker.init(ref args);
	Gtk.init(ref args);
	builder = new Builder();
	builder.add_from_file("T.yml");
	var experiment = builder.get_object("experiment") as Experiment;
	var run = experiment.add_run();
	experiment.prepare += (ex, run) => {
		message("prepare");
		camera.run = run;
		Vertex head = new Vertex();
		head.velocity = Vector(0.1, 0.1, 0.1);
		head.position = Vector(0.1, 0.1, 0.1);
		head.weight = 1.0;
		run.add_track(PType.neutron, head);
		run.frame_length = 1.0;
	};
	camera = new Camera();
	camera.use_solid = false;
	camera.run = run;

	experiment.attach_run(run);
	Gtk.Window window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
	window.add(camera);
	window.show_all();
	Gtk.main();
	return 0;
}
