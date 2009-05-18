using UCNTracker;

public double my_mfp_func(Part part, Vertex vertex) {
	return 1.0;
}
public int main(string[] args) {
	UCNTracker.init(ref args);
	Builder builder = new Builder();
	builder.add_from_string(
"""
---
- &experiment
  class : UCNExperiment
  children:
  - *part1
  - *part2
- &part2
  class : UCNPart
  children :
  - &ball
    class: UCNBall
    center: 1, 2, 3
    radius: 2.0
  - class: UCNCylinder
    center: 0, 0, 0
    radius: 2.0
    length: 3.0
...
""", -1);

	assert(builder.get_object("ball") != null);
	Ball ball = builder.get_object("ball") as Ball;
	message("%s", ball.center.to_string());
	message("%lf", ball.radius);
	return 0;
}
