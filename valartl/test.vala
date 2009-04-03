using Vala.Runtime.YAML;
using Vala.Runtime;

enum ENUM {
	ABCD
}

public class Experiment: Object, Buildable {
	
	}
public class Part : Object, Buildable {
	
}
public class Union: Object, Buildable {
	
}
public class Cylinder: Object, Buildable {
	
}
public int main() {
	Builder builder = new Builder();
	typeof(Experiment);
	typeof(Cylinder);
	typeof(Union);
	typeof(Part);

	builder.add_from_string(
"""
---
- &experiment
  class: Experiment
  children:
  - *TPipe
- &TPipe
  class: Part
  layer: 1
  children:
  - *T
- &T
  class: Union
  children:
  - &V
    class: Cylinder
    center: 0, 0, 0
    rotation: 0, 0, 0
    length: 8.0
    radius: 1.0
  - class: Cylinder
    center: 0, 0, 2
    rotation: 0, 90, 0
    length: 4.0
    radius: 1.0
...
""",
0
);
	assert(builder.get_object("T") != null);
	assert(builder.get_object("V") != null);
	return 0;
}
