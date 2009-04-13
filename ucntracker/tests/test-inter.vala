using GLib;
using UCNTracker;
using Vala.Runtime;

public int main(string[] args) {

	UCNTracker.init(ref args);
	Builder builder = new Builder();
	builder.add_from_string(
"""
---
- &is
  class: UCNIntersection
  children:
  - class: UCNBox
    center: 0, 0, 0
    size: 2, 2, 2
  - class: UCNBox
    center: 0, 0, 1
    size: 1, 1, 1
...
""", -1);

	Volume is = builder.get_object("is") as Volume;
	sample_volume(is, 100000);
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
