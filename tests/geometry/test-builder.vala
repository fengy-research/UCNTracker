using GLib;
using UCNTracker;
using Math;

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
	assert(obj.vector.x == 1.0 && obj.vector.y == 1.0 && obj.vector.z == 1.0);
}
public int main(string[] args) {
	test_builder();
	return 0;
}
