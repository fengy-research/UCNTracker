using GLib;
using UCNTracker;
using Math;

public void test_rotate(Vector v, EulerAngles r, Vector ex) {
	Vector tmp = v.clone();
	tmp.rotate(r);
	message("%lf %lf %lf -(%lf %lf %lf)-> %lf %lf %lf = %lf %lf %lf",
			v.x, v.y, v.z,
			r.alpha/PI, r.beta/PI, r.gamma/PI,
			tmp.x, tmp.y, tmp.z,
			ex.x, ex.y, ex.z);

	assert(tmp.equal(ex));
	tmp.rotate_i(r);
	assert(tmp.equal(v));
}
public void test_vector() {
	Vector vx = {1.0, 0.0, 0.0};
	Vector vy = {0.0, 1.0, 0.0};
	Vector vz = {0.0, 0.0, 1.0};
	EulerAngles eaz = EulerAngles(PI/2.0, 0.0, 0.0);
	EulerAngles eax = EulerAngles(0.0, PI/2.0, 0.0);
	EulerAngles eaZ = EulerAngles(0.0, 0.0, PI/2.0);

	test_rotate(vx, eaz, Vector(0.0, 1.0, 0.0));
	test_rotate(vy, eaz, Vector(-1.0, 0.0, 0.0));
	test_rotate(vz, eaz, Vector(0.0, 0.0, 1.0));
	test_rotate(vx, eax, Vector(1.0, 0.0, 0.0));
	test_rotate(vy, eax, Vector(0.0, 0.0, 1.0));
	test_rotate(vz, eax, Vector(0.0, -1.0, 0.0));
	test_rotate(vx, eaZ, Vector(0.0, 1.0, 0.0));
	test_rotate(vy, eaZ, Vector(-1.0, 0.0, 0.0));
	test_rotate(vz, eaZ, Vector(0.0, 0.0, 1.0));
}
public int main(string[] args) {
	test_vector();
	return 0;
}
