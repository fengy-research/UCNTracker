using GLib;
using UCNTracker;
using UCNTracker.Geometry;
using Math;

public int main(string[] args) {
	Box myvol = new Box(Vector(4.0, 4.0, 4.0));
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
				stdout.printf("%lf %lf %lf %lf %lf %lf %lf\n", p.x, p.y, p.z, g.x, g.y, g.z, myvol.sfunc(p));
			}
		}
	}
	return 0;
}
