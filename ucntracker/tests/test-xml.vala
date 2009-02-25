using GLib;
using UCNTracker;
using UCNTracker.Geometry;
using UCNTracker.Device;

public double my_mfp_func(Part part, Vertex vertex) {
	return 1.0;
}
public int main(string[] args) {
	UCNTracker.init(ref args);
	Builder builder = new Builder();
	builder.add_from_string(
"""
	<interface>
	<object class="UCNDeviceExperiment" id="experiment">
		<child>
		<object class="UCNDevicePart" id="part1">
			<property name="default-mean-free-path">2.0</property>
			<child>
			<object class="UCNGeometryBall" id="part1vol">
			<property name="center">1, 2, 3</property>
			<property name="radius">2.0</property>
			</object></child>
		</object></child>
		<child>
		<object class="UCNDevicePart" id="part2">
			<property name="mean-free-path-func">my_mfp_func</property>
			<child>
			<object class="UCNGeometryCylinder" id="part2vol">
				<property name="center">0, 0, 0</property>
				<property name="radius">1.0</property>
				<property name="length">3.5</property>
			</object></child>
		</object></child>
	</object>
	</interface>
""", -1);

	return 0;
}
