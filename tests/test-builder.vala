using UCNTracker;

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
---
- &experiment
  class : UCNExperiment
  children :
  - *environment
  - *part1
  - class : UCNAccelField
    accel : 0.1
- &environment
  class : UCNPart
  layer : -1
  children:
  - *env
- &part1
  class : UCNPart
  layer : 0
  children:
  - class : UCNBall
    radius : 2
    center : 1, 2, 3
  - *cs1
- &env
  class : UCNBall
  center : 0, 0, 0
  radius : 100
- &cs1
  class : CrossSection
  ptype: Neutron
  mfp : 1.0
...
""";
