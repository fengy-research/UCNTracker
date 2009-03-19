using GLib;
using Gtk;
using UCNTracker;
using UCNTracker.Geometry;
using UCNTracker.Device;

UCNTracker.Builder builder;
public int main(string[] args) {

	UCNTracker.init(ref args);
	Gtk.init(ref args);
	builder = new UCNTracker.Builder();
	builder.add_from_string(
"""
<interface>
<object class="UCNExperiment" id="experiment">
 <child>
  <object class="UCNDevicePart" id="environment">
   <property name="layer">-1</property>
   <child type="volume">
    <object class="UCNGeometryBall" id="envball">
     <property name="center">0, 0, 0</property>
     <property name="radius">100</property>
    </object>
   </child>
  </object>
 </child>
 <child>
  <object class="UCNDevicePart" id="part1">
   <property name="layer">0</property>
   <child type="volume">
    <object class="UCNGeometryBall" id="part1box">
     <property name="center">1, 2, 3</property>
     <property name="radius">2</property>
    </object>
   </child>
  </object>
 </child>
</object>
</interface>
""", -1);

	Experiment experiment = builder.get_object("experiment") as Experiment;
	Part environment = builder.get_object("environment") as Part;
	Part part1 = builder.get_object("part1") as Part;

	experiment.prepare += (obj, run) => {
		Vertex start = new Vertex();
		start.position = Vector(1.0, 1.0, -10.0);
		start.velocity = Vector(0.0, 0.0, 0.1);
		start.weight = 1.0;
		run.time_limit = 1000;
		message("run started");
		run.add_track(PType.neutron, start);
		run.track_motion_notify += (obj, track, prev) => {
			stdout.printf("%p %lf %s %s\n", track, track.tail.timestamp, 
			                       track.tail.vertex.position.to_string(),
			                       track.tail.vertex.velocity.to_string());
		};
		message("track added");
	};

	experiment.finish += (obj, run) => {
		message("run finished");
	};


	environment.hit += (obj, track, state) => {
		message("environment %p %lf", track, state.timestamp);
	};
	part1.hit += (obj, track, state) => {
		double length = track.get_double("length");
		length += track.estimate_distance(state);
		message("part1 %p %lf length = %f", track, state.timestamp, length);
		track.set_double("length", length);
	};

	part1.transport += (obj, track, leave, enter, transported)
	  => {
		Vector norm = track.tail.volume.grad(leave.vertex.position);
		leave.vertex.velocity.reflect(norm);
		
		track.run.fork_track(track, track.ptype, enter);
		*transported = false;
		message("fork %p", track);
	};

	Gtk.Window window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
	Gtk.Button button = new Gtk.Button.with_label("Start");
	window.add(button);
	button.clicked += (obj) => {
		message("clicked");
		Experiment ex
		= builder.get_object("experiment") as Experiment;
		Run run = ex.add_run();
		ex.attach_run(run);
	};
	window.show_all();
	Gtk.main();
	return 0;
}
