using GLib;
using GL;
using GLU;
using UCNTracker;
using UCNPhysics;

Builder builder;
UCNTracker.Camera gl;

public int main(string[] args) {

	UCNTracker.init(ref args);
	Gtk.init(ref args);
	Gtk.gl_init ( ref args);

	builder = new Builder("UCN");
	builder.add_from_string(GML);

	Experiment experiment = builder.get_object("experiment") as Experiment;
	assert(experiment != null);
	Part environment = builder.get_object("environment") as Part;
	Part part1 = builder.get_object("part1") as Part;
	CrossSection cs1 = builder.get_object("cs1") as CrossSection;

	experiment.prepare += (obj, run) => {
		Track t = Track.new(typeof(Neutron));
		Vertex start = t.create_vertex();
		start.position = Vector(1.0, 1.2, -10.0);
		start.velocity = Vector(0.0, 0.0, 2.0);
		start.weight = 1.0;
		run.time_limit = 1000;
		run.frame_length = 1.0;
		message("run started");
		t.start(run, start);
		message("track added");
	};

	experiment.finish += (obj, run) => {
		message("run finished");
	};

	cs1.hit += (obj, track, state) => {
		message("hit on track %p, at %s", track, state.position.to_string());
	};

	Gtk.Window window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
	Gtk.Button button = new Gtk.Button.with_label("Start");
	Gtk.Box vbox = new Gtk.VBox(false, 0);
	gl = new UCNTracker.Camera ();
	gl.set_size_request(200, 200);

	window.add(vbox);
	vbox.pack_start(button, false, false, 0);
	vbox.add(gl);

	Run run = experiment.add_run();
	gl.experiment = experiment;
	gl.use_solid = false;
	gl.run = run;
	button.clicked += (obj) => {
		message("clicked");
		Experiment ex
		= builder.get_object("experiment") as Experiment;
		ex.attach_run(gl.run);
	};
	window.show_all();
	Gtk.main();
	return 0;
}

private const string GML = 
"""
--- !Experiment &experiment
objects:
- !Part &part1
  layer: 1
  potential: 8.5e-5, 193
  objects:
  - !Box
    center: 0, 0, 0
    size: 3, 4, 5
  - !CrossSection &cs1
    const_sigma: 0.34barn
    density: 1.0
  neighbours:
    *Lab : { absorb: 100, diffuse: 0, fermi: 0 }
- !Part &Lab
  layer: 0
  objects:
  - !Ball
    center: 0, 0, 0
    radius: 30
...
""";
