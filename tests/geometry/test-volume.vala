
using GLib;
using UCNTracker;
using Math;

class MyVol : Volume, Buildable {
	public override double radius { get { return 3.0;}}
	public override double sfunc(Vector v) {
		/*Protect v from being changed.
		 * Definitely another vala bug. 
		 * gnome bz: 572091*/
		Vector p = v;
		world_to_body(ref p);
		double R = sqrt(p.x * p.x + p.y * p.y + p.z * p.z);
		return R - 3.0;
	}
}

public int main(string[] args) {
	MyVol myvol = new MyVol();
	assert(myvol is Buildable);

	Vector intersection;
	assert(true == myvol.intersect(Vector(-10.0, 0.0, 0.0),
			Vector(0.0, 0.0, 0.0),
			out intersection));

	message("%lf %lf %lf", 
			intersection.x,
			intersection.y,
			intersection.z);

	assert(false == myvol.intersect(Vector(-2.0, 0.0, 0.0),
			Vector(0.0, 0.0, 0.0),
			out intersection));


	myvol.center = Vector(0.0, 100.0, 0.0);
	myvol.rotation = EulerAngles(1.0, 3.0, 0.0);

	Vector sample;
	Vector grad;
	for(int i = 0; i< 1000; i++) {
		myvol.sample(out sample, true);
		myvol.grad(sample, out grad);
		stdout.printf("%lf %lf %lf %lf %lf %lf\n", 
				sample.x, sample.y, sample.z,
				grad.x, grad.y, grad.z);
	}
	return 0;
}
