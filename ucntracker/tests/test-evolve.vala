using GLib;
using UCNTracker;
using UCNTracker.Geometry;
using UCNTracker.Device;

public int main(string[] args) {

	UCNTracker.init(ref args);
	Builder builder = new Builder();
	builder.add_from_string(
"""
<interface>
<object class="UCNExperiment" id="experiment">
 <child>
  <object class="UCNDevicePart" id="enviroment">
   <child type="volume">
    <object class="UCNGeometryBall" id="envball">
     <property name="center">0, 0, 0</property>
     <property name="radius">100</property>
    </object>
   </child>
   <property name="layer">-1</property>
  </object>
 </child>
 <child>
  <object class="UCNDevicePart" id="part1">
   <child type="volume">
    <object class="UCNGeometryBall" id="part1box">
     <property name="center">1, 2, 3</property>
     <property name="radius">2</property>
    </object>
   </child>
    <property name="layer">-1</property>
  </object>
 </child>
</object>
</interface>
""", -1);

	Experiment experiment = builder.get_object("experiment") as Experiment;
	Part part1 = builder.get_object("part1") as Part;

	experiment.prepare += (obj, run) => {
		Vertex start = new Vertex();
		start.position = Vector(1.0, 2.0, -10.0);
		start.velocity = Vector(0.0, 0.0, 0.1);
		start.weight = 1.0;
		message("run started");
		run.add_track(PType.neutron, start);
		message("track added");
	};

	experiment.finish += (obj, run) => {
		message("run finished");
	};

	part1.hit += (obj, track, t, vertex) => {
		double length = track.get_double("length");
		length += track.distance_to(vertex);
		message("hit: %lf new length = %f", t, length);
		track.set_double("length", length);
	};

	part1.transport += (obj, track, next_part, v_leave, v_enter, transported)
	  => {
		Vector norm = track.tail.volume.grad(v_leave.position);
		v_leave.velocity.reflect(norm);
		
		transported = false;
		message("norm %lf %lf %lf",
		    norm.x,
		    norm.y,
		    norm.z);
		
		/*
		message("transport %lf %lf %lf",
		    v_leave.velocity.x,
		    v_leave.velocity.y,
		    v_leave.velocity.z
		);*/
	};

	experiment.run();
	return 0;
}
