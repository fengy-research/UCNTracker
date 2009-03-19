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
<object class="UCNGeometryBox" id="box1">
 <property name="center">0, 0, 0</property>
 <property name="size">2, 2, 2</property>
</object>
<object class="UCNGeometryBox" id="box2">
 <property name="center">0, 0, 1</property>
 <property name="size">1, 1, 1</property>
</object>
<object class="UCNGeometryUnion" id="union">
  <child ref="box1"/>
  <child ref="box2"/>
</object>
</interface>
""", -1);

	Volume union = builder.get_object("union") as Volume;
	sample_volume(union, 1000);
	return 0;
}

private void sample_volume(Volume volume, int points) {
	for(int i = 0; i < points; i++) {
		Vector point = volume.sample(true);
		Vector grad = volume.grad(point);
		stdout.printf("%s %s %lf\n", point.to_string(), grad.to_string(),
		volume.sfunc(point));
	}
}
