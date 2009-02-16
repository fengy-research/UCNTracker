
using GLib;
using UCNTracker;
using Math;

class MyVol : Volume, Buildable {
	private Gsl.RNG rng = new Gsl.RNG(Gsl.RNGTypes.mt19937);
	public override void sample_surface(out Vector point) {
		double x, y, z;
		Gsl.Randist.dir_3d( rng, out x, out y, out z);
		point = Vector(x, y, z);
		body_to_world(ref point);
	}
	public override void sample(out Vector point, bool open) {
		double x, y, z;
		double r;
		Gsl.Randist.dir_3d( rng, out x, out y, out z);
		r = rng.uniform();
		r = sqrt(r) * 3.0;
		do{
			point = Vector(x * r, y * r, z * r);
		} while(open && sense(point) == Sense.ON);
		body_to_world(ref point);
	}
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
	myvol.intersect(Vector(-10.0, 0.0, 0.0),
			Vector(0.0, 0.0, 0.0),
			out intersection);
	myvol.center = Vector(0.0, 100.0, 0.0);
	myvol.rotation = EulerAngles(1.0, 3.0, 0.0);

	message("%lf %lf %lf", 
			intersection.x,
			intersection.y,
			intersection.z);
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
