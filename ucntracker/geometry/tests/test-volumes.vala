using GLib;
using UCNTracker;
using UCNTracker.Geometry;
using Math;


PluginModuleManager manager;
public int main(string[] args) {
	manager = new PluginModuleManager();
	manager.query_static("ucn_geometry_init");
	message("%d", typeof(Box));
	Builder builder = new Builder();
	builder.add_from_file("volumes.xml");
	typeof(Volume); /*workaroudn vala Bug 572920*/
	weak SList<weak Volume> volumes = builder.get_objects();

	Vector p;
	foreach(Volume v in volumes) {
		stdout.printf("# %s\n", v.get_name());
		for(int i = 0; i< 100000; i++) {
			v.sample(out p, true);
			assert(v.sense(p) == Sense.IN);
			stdout.printf("%lf %lf %lf\n", p.x, p.y, p.z);
			stdout.flush();
		}
		stdout.printf("\n\n");
	}
	return 0;
}
