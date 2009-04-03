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
		Vertex start = new Vertex();
		start.position = Vector(1.0, 1.2, -10.0);
		start.velocity = Vector(0.0, 0.0, 2.0);
		start.weight = 1.0;
		run.time_limit = 1000;
		message("run started");
		Track t = run.add_track(PType.neutron, start);
		message("track added");
	};

	experiment.finish += (obj, run) => {
		message("run finished");
	};

	/*
	part1.hit += (obj, track, state) => {
	};*/

	part1.transport += (obj, track, leave, enter, transported)
	  => {
		Vector norm = track.tail.volume.grad(leave.position);
		leave.velocity.reflect(norm);
		
		Track t = track.run.fork_track(track, track.ptype, enter);

		*transported = false;
		message("fork %p", track);
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
private const string useless = """
<interface>
<object class="UCNExperiment" id="experiment">
 <child>
  <object class="UCNPart" id="environment">
   <property name="layer">-1</property>
   <child type="volume">
    <object class="UCNBall" id="envball">
     <property name="center">0, 0, 0</property>
     <property name="radius">100</property>
    </object>
   </child>
  </object>
 </child>
 <child>
  <object class="UCNGField" id="gfield">
   <property name="g">0.1</property>
   <child type="volume" ref="envball"/>
  </object>
 </child>
 <child>
  <object class="UCNPart" id="part1">
   <property name="layer">0</property>
   <child type="volume">
    <object class="UCNBall" id="part1box">
     <property name="center">1, 2, 3</property>
     <property name="radius">2</property>
    </object>
   </child>
  </object>
 </child>
 <child>
  <object class="UCNPart" id="part2">
   <property name="layer">-2</property>
   <child type="volume">
    <object class="UCNCylinder">
     <property name="center">1, 2, 3</property>
     <property name="radius">2</property>
     <property name="length">10</property>
    </object>
   </child>
   <child type="volume">
    <object class="UCNBox">
     <property name="center">1, 2, 3</property>
     <property name="size">6,8,10</property>
    </object>
   </child>
  </object>
 </child>
</object>
</interface>""";