using Vala.Runtime.YAML;
using Vala.Runtime;

enum ENUM {
	ABCD
}

public int main() {
	Parser p = new Parser();
	p.node_start = (obj, node) => {
		message("key started : %s", node.key);
	};
	p.node_end = (obj, node) => {
		message("key ended   : %s", node.key);
	};
	Context c = new Context(p);
	
	c.parse(
"""
---
- object: &experiment
  class: Experiment
  layer: 1
  children:
  - object: *TPipe
- object: &TPipe
  class: Part
  children:
  - object: *T
- object: &T
  class: Union
  children:
  - object: &V
    class: Cylinder
    center: 0, 0, 0
    rotation: 0, 0, 0
    length: 8.0
    radius: 1.0
  - object: &H
    type: Cylinder
    center: 0, 0, 2
    rotation: 0, 90, 0
    length: 4.0
    raius: 1.0
...
"""
);
	foreach(weak YAML.Node k in c.documents) {
		message("%s", k.to_string_r());
	}
	return 0;
}
