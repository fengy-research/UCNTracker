using GLib;
using GL;
using GLU;
using UCNTracker;
using UCNPhysics;
using Endf;

public class Application :UCNTracker.VisSimulation {
	private bool paused = false;
	public override void init() throws GLib.Error {
		base.init();

		var part1= get_part("part1");
		var lab = get_part("Lab");
		var b1 = part1.get_border(lab);
		var cs1 = get_cross_section("cs1");

		b1.transport += () => {
			message("transport");
			current_run.pause();
			paused = true;
		};

		/*
		cs1.sigmafunc = (track, vertex) => {
			double E = vertex.velocity.norm2() * track.mass * 0.5;
			double E_in_EV = E / ( 1.0 * UNITS.EV);
			double s = mf7mt2.S(E_in_EV, T) * UNITS.BARN;
			message(" E_in_EV = %lg Sigma = %lg", E_in_EV, s);
			return s;
		};*/

		cs1.hit += (obj, track, vertex) => {
			message("hit on track %p, at %s", track, vertex.position.to_string());
			/*
			double E = vertex.velocity.norm2() * track.mass * 0.5;
			double E_in_EV = E / ( 1.0 * UNITS.EV);
			double theta = mf7mt2.angular(UniqueRNG.rng, E_in_EV, T);
			double phi = UniqueRNG.rng.uniform() * Math.PI * 2.0;
			Quaternion q = Quaternion.from_two_vectors(
				Vector(1, 0, 0),
				Vector(Math.sin(theta) * Math.cos(phi), 
					Math.sin(theta) * Math.sin(phi), Math.cos(theta)));

			message("q = %s", q.to_string());
			message("theta = %lf, phi = %lf", theta, phi);
			message("velocity before hit = %s ", vertex.velocity.to_string());
			vertex.velocity = q.rotate_vector(vertex.velocity);
			message("velocity after hit = %s ", vertex.velocity.to_string());
			*/
			current_run.pause();
			paused = true;
		};

		if(!first_time_init) return;


		prepare += (obj, run) => {
			Track t = Track.new(typeof(Neutron));
			Vertex start = t.create_vertex();
			start.position = Vector(0, 0, 0);
			start.velocity = Vector(100000.0, 100000.0, 000.0);
			start.weight = 1.0;
			run.time_limit = 1000;
			run.frame_length = 1.0;
			message("run prepared ");
			t.start(run, start);
			message("track added");
			run.track_motion_notify += (r, t, v) => {
			//	r.run_motion_notify();
			};
		};

		finish += (obj, run) => {
			message("run finished");
		};

		Gtk.Button button = new Gtk.Button.with_label("Start");

		widget_box.pack_start(button, false, false, 0);

		button.clicked += (obj) => {
			message("clicked");
			if(paused) {
				current_run.continue();
			} else {
				init_from_string(GML);
				add_run().attach();
			}
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
    size: 10, 10, 5
#  - !Cylinder
#    center: 0, 0, 10
#    length: 10
#    radius: 10
#  - !Donut
#    center: 12, 12, 0 
#    tube_radius: 3
#    radius: 6
  cross-sections:
  - !CrossSection &cs1
    ptype: Neutron
    const_sigma: 0.1
    density: 6.0e23
  neighbours:
    *Lab : { absorb: 0, reflect : 00, diffuse: 100, fermi: 0 }
- !Part &Lab
  layer: 0
  volumes:
  - !Ball
    center: 0, 0, 0
    radius: 30
  neighbours:
    *part1 : { absorb: 00, reflect: 000, diffuse: 00, fermi: 0 }
#foils:
#- !Foil &foil
#  surfaces:
#  - !Rectangle
#    width: 100
#    height: 100
#  border: { absorb: 00, reflect: 000, diffuse: 100, fermi: 0 }
fields:
- !AccelField
  direction: 0, 0, -1
  accel: 980
...
""";
