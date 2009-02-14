using GLib;

class MyObject : Object {
	public int prop;
	public MyObject child {get; construct set;}
}

public int main(string[] args) {
	Builder builder = new Builder();
	builder.add_from_file("test.xml");
	MyObject object1 = builder.get_object("object1") as MyObject;
	MyObject object2 = builder.get_object("object2") as MyObject;

	assert(object2.child == object1);
	return 0;
}
