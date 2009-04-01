using UCNTracker;
using Gtk;

UCNTracker.Builder builder;
Camera camera;
public int main(string[] args) {
	UCNTracker.init(ref args);
	Gtk.init(ref args);
	builder = new UCNTracker.Builder();
	builder.add_from_file("T.xml");
	var experiment = builder.get_object("experiment") as Experiment;
	var run = experiment.add_run();
	experiment.attach_run(run);
	experiment.prepare += (ex, run) => {
		camera.run = run;
		Vertex head = new Vertex();
		head.velocity = Vector(0.0, 0.0, 0.1);
		head.position = Vector(0.0, 0.0, 0.0);
		run.add_track(PType.neutron, head);
	};
	camera = new Camera();
	camera.run = run;
	camera.use_solid = false;
	Gtk.Window window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
	window.add(camera);
	window.show_all();
	Gtk.main();
	return 0;
}
