using GLib;
using GL;
using GLU;
using UCNTracker;
using UCNPhysics;

public class Application :UCNTracker.VisSimulation {
	public override void init() throws GLib.Error {
		base.init();

		var part1= get_part("part1");
		var lab = get_part("Lab");
		var b1 = part1.get_border(lab);
		var cs1 = get_cross_section("cs1");

		if(!first_time_init) return;

		prepare += (obj, run) => {
			Track t = Track.new(typeof(Neutron));
			Vertex start = t.create_vertex();
			start.position = Vector(1.0, 1.2, 10.0);
			start.velocity = Vector(0.0, rng.uniform(), 2.0);
			start.weight = 1.0;
			run.time_limit = 1000;
			run.frame_length = 1.0;
			message("run prepared ");
			t.start(run, start);
			message("track added");
		};

		finish += (obj, run) => {
			message("run finished");
		};

		b1.transport += () => {
			message("transport");
		};

		cs1.hit += (obj, track, state) => {
			message("hit on track %p, at %s", track, state.position.to_string());
		};

		Gtk.Button button = new Gtk.Button.with_label("Start");

		widget_box.pack_start(button, false, false, 0);

		button.clicked += (obj) => {
			message("clicked");
			init_from_string(GML);
			message("clicked-2");
			add_run().attach();
		};
		
	}

	public static int main(string[] args) {

		UCNTracker.init(ref args);
		UCNTracker.set_verbose(true);

		Application sim = new Application();
		sim.init_from_string(GML);

		sim.run(false, false);

		return 0;
	}

}

private const string GML = 
"""
--- !Experiment &experiment
parts:
- !Part &part1
  layer: 1
  potential: { f : 8.5e-5 , V : 193 }
  volumes:
  - !Box
    center: 0, 0, 0
    size: 3, 4, 5
  cross-sections:
  - !CrossSection &cs1
    const_sigma: 0.34barn
    density: 1.0
  neighbours:
    *Lab : { absorb: 50, diffuse: 50, fermi: 0 }
- !Part &Lab
  layer: 0
  volumes:
  - !Ball
    center: 0, 0, 0
    radius: 30
fields:
- !AccelField
  direction: 0, 0, -1
  accel: 980
...
""";
