using GLib;
using UCNTracker;
using UCNTracker.Geometry;
using UCNTracker.Device;

const string template = """
<interface>
<object class="%s" id="primitive">
 <property name="center">0, 0, 0</property>
 <property name="radius">100</property>
</object>
</interface>
""";

private void sample_volume(string classname, int points) {
	string gdl = template.printf(classname);
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
	if(args.length >= 2) {
		for(int i = 1; i< args.length; i++) {
			sample_volume(args[i], 1000);
		}
	}
	return 0;
}
