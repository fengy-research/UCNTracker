using GLib;
using UCNTracker;
using Vala.Runtime;

public int main(string[] args) {

	UCNTracker.init(ref args);
	Builder builder = new Builder();
	builder.add_from_file("/dev/stdin");

	Volume union = builder.get_object(args[1]) as Volume;
	int points = args[2].to_int();
	sample_volume(union, points);
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
