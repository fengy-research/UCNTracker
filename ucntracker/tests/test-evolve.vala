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
		<object class="UCNDevicePart" id="part1">
			<child type="volume"><object class="UCNGeometryBox" id="part1box">
			<property name="center">1, 2, 3</property>
			<property name="size">2,2,2</property>
			</object></child>
 		</object>
		</child>
		</object>
	</interface>
""", -1);
	Experiment experiment = builder.get_object("experiment") as Experiment;
	Part part1 = builder.get_object("part1") as Part;

	experiment.prepare += (obj, run) => {
		Vertex start = new Vertex();
		start.position = Vector(1.0, 2.0, 3.0);
		start.velocity = Vector(0.0, 0.0, 0.1);
		start.weight = 1.0;
		message("run started");
		run.add_track(PType.neutron, start);
		message("track added");
	};
	experiment.finish += (obj, run) => {
		message("run finished");
	};
	part1.hit += (obj, vertex) => {
		message("hit!");
	};
	part1.transport += (obj, track, next, v_leave, v_enter) => {
		message("transport");	
	};
	experiment.run();
	return 0;
}
