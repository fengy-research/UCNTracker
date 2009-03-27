using Vala.Runtime.YAML;

public int main() {
	Parser p = new Parser();
	Context c = new Context(p);
	
	c.add_string(
"""
---
GObject: &H

GObject: &root
  props :
    foo : foo-value
    bar : bar-value
  children :
    GObject : *H
    GObject :
      props :
        foo : foo-value1
        bar : bar-value2
...
""");
	foreach(weak Key k in c.documents) {
		message("%s", k.to_string());
	}
	return 0;
}
