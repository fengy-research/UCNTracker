using GLib;
using UCNTracker;
using Vala.Runtime;

public int main(string[] args) {

	UCNTracker.init(ref args);
	Builder builder = new Builder("UCN");
	builder.add_from_file("/dev/stdin");

	Object obj = builder.get_object(args[1]) as Object;
	int points = args[2].to_int();
	if(obj is UCNTracker.Part) {
		sample_part(obj as UCNTracker.Part, points);
	}
	if(obj is UCNTracker.Volume) {
		sample_volume(obj as UCNTracker.Volume, points);
	}
	return 0;
}

private void sample_volume(UCNTracker.Volume volume, int points) {
	for(int i = 0; i < points; i++) {
		Vector point = volume.sample(true);
		Vector grad = volume.grad(point);
		stdout.printf("%s %s %lf\n", point.to_string(), grad.to_string(),
		volume.sfunc(point));
	}
}

private void sample_part(Part part, int points) {
	foreach(UCNTracker.Volume volume in part.volumes) {
		sample_volume(volume, points);
	}
}
