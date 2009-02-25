using GLib;


public class MyClass {
	public Node<Object> node;
	public void run() {
		Object[] objects = new Object[100];
		for(int i = 0; i < 100; i++) {
			objects[i] = new Object();
			objects[i].set_data("id", (void*) i);
		}

		node = new Node<Object>();
		node.data = objects[0];
		node.append_data(objects[1]);
		node.append_data(objects[2]);
		node.append_data(objects[3]);
		weak Node child;
		child = node.find_child(TraverseFlags.ALL, objects[1]);
		assert(child != null);
		child.append_data(objects[11]);
		child.append_data(objects[12]);
		child.append_data(objects[13]);
		child = node.find_child(TraverseFlags.ALL, objects[2]);
		assert(child != null);
		child.append_data(objects[21]);
		child.append_data(objects[22]);
		child.append_data(objects[23]);
		node.traverse(TraverseType.PRE_ORDER, TraverseFlags.ALL, -1, traverse_func);
		message("safdqwef");
	}	
	private bool traverse_func(Node<Object> node) {
		message("%d", (int) node.data.get_data("id"));
		return false;
	}
}
public int main(string[] args) {
	MyClass obj = new MyClass();
	obj.run();
	return 0;
}
