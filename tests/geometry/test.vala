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
class MyObject:Object {
	public Vector vector {get; set;}

}
public void test_builder() {
string xml = """
<interface>
	<object class="MyObject" id="object">
		<property name="vector">1.0, 2.0, 3.0</property>
	</object>
</interface>
	""";
	Builder builder = new Builder();
	builder.add_from_string(xml, xml.length);
	MyObject obj = builder.get_object("object") as MyObject;

	message("%lf %lf %lf", obj.vector.x, obj.vector.y, obj.vector.z);

}
public int main(string[] args) {
	test_vector();
	test_builder();
	return 0;
}
