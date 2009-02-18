

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
	Vector p = Vector(0.0, 0.0, 0.0);
	for(int i = -10; i < 10; i++) {
		for(int j = -10; j< 10; j++) {
			for(int k = -10; k<10; k++) {
				p.x = i * 0.5;
				p.y = j * 0.5;
				p.z = k * 0.5;
				Vector g;
				myvol.grad(p, out g);
				stdout.printf("%lf %lf %lf %lf %lf %lf\n", p.x, p.y, p.z, g.x, g.y, g.z);
			}
		}
	}
	return 0;
}
