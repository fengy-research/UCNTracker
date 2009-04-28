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
		run.attach();
		run.pause();
	};

	experiment.finish += (ex, run) => {
		message("run finished");
		foreach(var track in run.tracks) {
			message("%lg", track.tail.weight);
		}
	};
	var guide = builder.get_object("Guide") as Part;
	guide.transport += (part, track, leave, enter, transported) => {
		assert(enter.part != leave.part);
			message("weight = %lf", leave.weight);
		if(enter.part.get_name() == "Disc") {
			track.terminate();
		} else {
			part.optic_reflect(part, track, leave, enter, transported);
			Vector norm = leave.volume.grad(leave.position);
			double f = 8.5e-5;
			double V = 150.0e-9 * UNITS.EV;
			double E = 0.5 * track.mass * leave.velocity.norm2();
			double cos_s = leave.velocity.direction().dot(norm);
			message("mass = %lg E = %lg V = %lg cos_s = %lf", track.mass, E, V, cos_s);
			double Ecos2_s = E * cos_s * cos_s;
			if(Ecos2_s > V) {
				double r = 1.0 - 2.0 * f * Math.sqrt(Ecos2_s/(Ecos2_s - V));
				leave.weight *= r;
			}
		}
		track.run.pause();
	};

	camera = new Camera();
	camera.use_solid = false;
	camera.experiment = experiment;

	camera.run = run;
	camera.set_size_request(200, 200);
	Gtk.Window window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
	Gtk.Box box = new Gtk.VBox(false, 0);
	Gtk.Button button = new Gtk.Button.with_label("go");
	box.pack_start(camera, true, true, 0);
	box.pack_start(button, false, false, 0);
	button.clicked += run.@continue;
	window.add(box);
	window.show_all();
	Gtk.main();
	return 0;
}
