using UCNTracker;
using GLib.YAML;

Builder builder;

public int main(string[] args) {

	UCNTracker.init(ref args);

	builder = new Builder("UCN");
	builder.add_from_string(GML);

	Experiment experiment = builder.get_object("experiment") as Experiment;
	assert(experiment != null);

	return 0;
}

private const string GML = 
"""
# version 2
# The goal is to be able to parse this file with libyaml & libyaml glib
# pretty much already there?
# w hours work ahead.

--- !Experiment &experiment
objects:
- !Part &Cell
  layer: 1
  potential: { f: 8.5e-5, V: 193nev }
  objects:
  - !Box
    center: { x: 0, y: 0, z: 0 }
    size: [ 3cm, 4cm, 5cm ]
  - !CrossSection &CS_UP
    const_sigma: 0.34barn
    density: 1.0
  neighbours:
  - *Lab : { absorb: 50%, diffuse: 40%, fermi: 10% }
- !Part &Lab
  layer: 0
  objects:
  - !Ball
    center: [ 0, 0, 0 ]
    radius: 30
...
""";

