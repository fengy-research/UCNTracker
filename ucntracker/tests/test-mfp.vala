using UCNTracker;

public int main(string[] args) {

	UCNTracker.init(ref args);
	Builder builder = new Builder();
	builder.add_from_string(
"""
<interface>
<object class="UCNExperiment" id="experiment">
 <child>
  <object class="UCNPart" id="env">
   <property name="layer">-1</property>
   <property name="mfp">1000</property>
   <child type="volume">
    <object class="UCNBox">
     <property name="center">0, 0, 0</property>
     <property name="size">100, 100, 100</property>
    </object>
   </child>
  </object>
 </child>
 <child>
  <object class="UCNPart" id="thicker">
   <property name="layer">0</property>
   <property name="mfp">0.1</property>
   <child type="volume">
    <object class="UCNBox">
     <property name="center">0, 0, 1</property>
     <property name="size">2, 2, 1</property>
    </object>
   </child>
  </object>
 </child>
 <child>
  <object class="UCNPart" id="thinner">
   <property name="layer">0</property>
   <property name="mfp">0.01</property>
   <child type="volume">
    <object class="UCNBox">
     <property name="center">0, 0, 0</property>
     <property name="size">2, 2, 1</property>
    </object>
   </child>
  </object>
 </child>
</object>
</interface>
""", -1);

	Experiment experiment = builder.get_object("experiment") as Experiment;
	Part environment = builder.get_object("environment") as Part;
	Part thicker = builder.get_object("thicker") as Part;
	Part thinner = builder.get_object("thinner") as Part;

	message("%lf", thicker.mfp);
	assert(thicker.mfp == 0.1);
	experiment.prepare += (obj, run) => {
		Vertex start1 = new Vertex();
		start1.position = Vector(-1.0, 0.0, 1.0);
		start1.velocity = Vector(0.1, 0.0, 0.0);
		start1.weight = 1.0;

		Vertex start2 = new Vertex();
		start2.position = Vector(-1.0, 0.0, 0.0);
		start2.velocity = Vector(0.1, 0.0, 0.0);
		start2.weight = 1.0;

		message("run started");
		run.time_limit = 1000;
		run.add_track(typeof(Neutron), start1);
		run.add_track(typeof(Neutron), start2);

		run.track_motion_notify += (obj, track, prev) => {
			stdout.printf("%p %lf %s %s\n", track, track.tail.timestamp, 
			                       track.tail.position.to_string(),
			                       track.tail.velocity.to_string());
		};
		message("track added");
	};

	experiment.finish += (obj, run) => {
		message("run finished");
	};


	thinner.hit += (obj, track, state) => {
		message("thinner hit %p %lf", track, state.timestamp);
	};

	thicker.hit += (obj, track, state) => {
		message("thicker hit %p %lf", track, state.timestamp);
	};

	experiment.run();
	return 0;
}
