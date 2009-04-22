using GLib;
using GL;
using GLU;
using Vala.Runtime;
using UCNTracker;
Builder builder;
UCNTracker.Camera gl;

public int main(string[] args) {

	UCNTracker.init(ref args);
	Gtk.init(ref args);
	Gtk.gl_init ( ref args);

	builder = new Builder();
	builder.add_from_string(GML, -1);

	Experiment experiment = builder.get_object("experiment") as Experiment;
	assert(experiment != null);
	Part environment = builder.get_object("environment") as Part;
	Part part1 = builder.get_object("part1") as Part;

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

	/*
	part1.hit += (obj, track, state) => {
	};*/

/*	part1.transport += (obj, track, leave, enter, transported)
	  => {
		Vector norm = track.tail.volume.grad(leave.position);
		leave.velocity.reflect(norm);
		
		Track t = track.run.fork_track(track, track.ptype, enter);

		*transported = false;
		message("fork %p", track);
	};*/
	part1.transport += part1.optic_reflect;

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
---
- &experiment
  class : UCNExperiment
  children :
  - *environment
  - *part1
  - class : UCNGravityField
    g : 0.1
    children:
    - *env
- &environment
  class : UCNPart
  layer : -1
  children:
  - *env
- &part1
  class : UCNPart
  layer : 0
  children:
  - class : UCNBall
    radius : 2
    center : 1, 2, 3
- &env
  class : UCNBall
  center : 0, 0, 0
  radius : 100
...
""";
