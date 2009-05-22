using UCNTracker;
using UCNPhysics;
Builder builder;

int N_TRACKS = 1;
public class Application: Simulation {
	
	public override void init() throws GLib.Error {
 		base.init();

		var cell = get_part("Cell");
		var up = get_cross_section("up");
		var down = get_cross_section("down");

		prepare += (obj, run) => {
			var volume = cell.volumes.data; /* the first volume*/
			message("run prepare");
			for(int i = 0; i < N_TRACKS; i++) {
				var track = Track.new(typeof(Neutron));
				Vertex head = track.create_vertex();
				head.position = volume.sample(true);
				Vector v = Vector(0.0, 0.0, 0.0);
				Gsl.Randist.dir_3d(UniqueRNG.rng, out v.x, out v.y, out v.z);
				head.velocity = v;
				head.weight = 1.0;
				head.velocity.mul(0.1);
				track.set_vector("in", head.position);
				track.set_vector("in-vel", head.velocity);
				track.start(run, head);
			}
		};
		finish += (obj, run) => {
			foreach (Track track in run.tracks) {
				Vector @in = track.get_vector("in");
				Vector in_vel = track.get_vector("in-vel");
				Vector @out = track.get_vector("out");

				stdout.printf("%s %s %s %lf %lf\n", 
					@in.to_string(),
					in_vel.to_string(),
					@out.to_string(),
					track.length,
					track.get_double("#scatters")
					);
			}
			message("finished");
		};
		up.hit += (obj, track, state) => {
			message("up hitted");
		};
		
	}
	public static int main(string[] args) {
		UCNTracker.init(ref args);
		UCNTracker.set_verbose(true);
		Application sim = new Application ();
		sim.init_from_file("geometry.yml");
		sim.run();
		return 0;

	}
}
