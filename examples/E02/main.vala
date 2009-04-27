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
		Track track = Track.new(typeof(Neutron));
		Vertex head = track.create_vertex_with_kinetics(
			500e-9 * UNITS.EV, Vector(0.0, 1.0, 0.0));
		head.position = Vector(0.0, 1.0, 0.0);
		head.weight = 1.0;
		track.start(run, head);
		run.frame_length = 0.01;
	};

	var guide = builder.get_object("Guide") as Part;
	guide.transport += (part, track, enter, leave, transported) => {
		assert(enter.part != leave.part);
		if(leave.part.get_name() == "Disc") {
			track.terminate();
		} else {
			part.optic_reflect(part, track, enter, leave, transported);
		}
	};

	camera = new Camera();
	camera.use_solid = false;
	camera.experiment = experiment;

	camera.run = run;
	camera.set_size_request(200, 200);
	experiment.attach_run(run);
	Gtk.Window window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
	Gtk.Box box = new Gtk.VBox(false, 0);
	Gtk.Button button = new Gtk.Button.with_label("go");
	box.pack_start(camera, true, true, 0);
	box.pack_start(button, false, false, 0);
	window.add(box);
	window.show_all();
	Gtk.main();
	return 0;
}
