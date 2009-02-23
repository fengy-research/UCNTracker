using GLib;
using UCNTracker;
using UCNTracker.Geometry;
using Math;

class TypeModule:GLib.TypeModule {
	public override bool load() {
		return true;
	}
	public override void unload() {}
}
public int main(string[] args) {
	TypeModule module = new TypeModule();
	Geometry.init(module);
	Builder builder = new Builder();
	builder.add_from_file("volumes.xml");
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
