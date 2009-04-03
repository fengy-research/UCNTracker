using GLib;
using UCNTracker;
using Vala.Runtime;

const string gdl = """
<interface>
<object class="UCNCylinder" id="primitive">
 <property name="center">0, 0, 0</property>
 <property name="rotation">0.0,0.785,0.0</property>
 <property name="radius">10</property>
 <property name="length">10</property>
</object>
</interface>
""";

private void sample_volume(int points) {
	Builder builder = new Builder();

	builder.add_from_string(gdl, -1);
	Volume volume = builder.get_object("primitive") as Volume;
	for(int i = 0; i < points; i++) {
		Vector point = volume.sample(true);
		stdout.printf("%lf %lf %lf\n", point.x, point.y, point.z);
	}
}
public int main(string[] args) {
	UCNTracker.init(ref args);
	sample_volume( 10000);
	return 0;
}
