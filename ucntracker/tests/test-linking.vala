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
		<object class="UCNDevicePart" id="part1">
			<child type="volume"><object class="UCNGeometryBall" id="part1vol">
			<property name="center">1, 2, 3</property>
			<property name="radius">2.0</property>
			</object></child>
 		</object>
	</interface>
""", -1);

	return 0;
}
