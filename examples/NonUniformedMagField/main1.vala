using GLib;
using GL;
using GLU;
using UCNTracker;
using UCNPhysics;
using Math;


public class Simulation : UCNTracker.Simulation {
	static int number_tracks = 1;
	static string prefix;
	double energy = 0.0;
	double sp = 0.0;
	CustomField MagF;
	AccelField GF;
	Part Lab;
	Part Ctn;
	Box box;
	FileStream[] FSp = null;
	static const OptionEntry[] options = {
			{"track-number", 't', 0, OptionArg.INT, ref number_tracks, "Number of neutrons", "N"},
			{"prefix", 'p', 0, OptionArg.STRING, ref prefix, "Prefix of output files", "Prefix"},
			{null}
		};

	public override void init() throws GLib.Error {
		base.init();
		MagF = builder.get_object("Mag") as CustomField;
		GF = builder.get_object("G") as AccelField;
		Lab = get_part("Lab");
		Ctn = get_part("Container");
		box = get_volume("box") as Box;
		FSp = new FileStream[number_tracks];
		for(int i = 0; i < number_tracks; i++) {
			FSp[i] = FileStream.open("%s-%d".printf(prefix, i), "w");
		}
		MagF.function = (track, Q, dQ) => {
			double k = 0.00005;
			double B = k * Math.pow(Math.pow(10 - 0.1 * Q.position.z, 2) + 0.0025 * (Math.pow(Q.position.x, 2) + Math.pow(Q.position.y, 2)), 0.5) * UNITS.TESLA;
			dQ.spin_precession += track.spin_parallel * track.mdm * B / (1.0 * UNITS.H_BAR);
			dQ.velocity.x += track.spin_parallel * track.mdm * Math.pow(k, 2) * 0.0025 * Q.position.x / ( B * track.mass );
			dQ.velocity.y += track.spin_parallel * track.mdm * Math.pow(k, 2) * 0.0025 * Q.position.y / ( B * track.mass );
			dQ.velocity.z += track.spin_parallel * track.mdm * Math.pow(k, 2) * ( -0.1 ) * ( 10 - 0.1 * Q.position.z ) / ( B * track.mass );
			return true;
		};
			
		prepare += (ex, run) => {
			run.run_motion_notify += (run) => {
				int a;
				foreach(Track track in run.tracks) {
					a = (int)track.get_double("track");
					message("spin precession of track %d: %lf\n", a, track.tail.spin_precession);
					FSp[a].printf(" %le %lf %s \n", track.tail.timestamp, track.tail.spin_precession, track.tail.position.to_string());
				}
			};
			init_track(run);
			run.time_limit = 1;
			run.frame_length = 0.0001;
		};
		
		finish += (ex, run) => {
			summerize(run);
		};
		
	}

	private bool init_track(Run run) {
		var dist = new UCNTracker.Randist.PDFDist();
		var v_dist = new UCNTracker.Randist.PDFDist();
		dist.left = 0;
		dist.right = 1.57;
		dist.pdf = (x) => {return Math.pow(Math.cos(x), 2.8);};
		dist.init();
		v_dist.left = 0;
		v_dist.right = 7.150;
		v_dist.pdf = (x) => {
			if(x < 5.28) return pow(x, 2.9);
			return pow(5.28, 2.9)/1.87 * (7.15 - x);
		};
		v_dist.init();
		if(number_tracks == 0) return false;
		for(int i = 0; i< number_tracks; i++) {
			Track track = Track.new(typeof(Neutron));
			double theta = dist.next(rng);
			double phi = 2.0 * rng.uniform() * 3.14;
			Vector dir = Vector( sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta) );
			energy = v_dist.next(rng) * UNITS.M;
			energy = 0.5 * track.mass * energy * energy;
			Vertex head = track.create_vertex_with_kinetics(energy, dir);
			double x, y, z;
			x = box.center.x + ( rng.uniform() - 0.5 ) * box.size.x;
			y = box.center.y + ( rng.uniform() - 0.5 ) * box.size.y;
			z = box.center.z + ( rng.uniform() - 0.5 ) * box.size.z;
			head.position = Vector(x, y, z);
			head.weight = 1.0;
			head.spin_precession = 0;
			track.spin_parallel = rng.uniform() * 2 - 1;
			track.start(run, head);
			track.set_double("track", i * 1.0);
		}
		return true;
	}

	public static int main(string[] args) {
		UCNTracker.init(ref args);
		UCNTracker.set_verbose(true);
		UCNTracker.set_absolutely_quiet(false);
		Simulation sim = new Simulation();
		OptionContext ctxt = new OptionContext("Track neutrons under magnetic field:");
		ctxt.add_main_entries(options, null);
		ctxt.set_help_enabled(true);
		ctxt.parse(ref args);
		sim.init_from_file("T.yml");
		sim.run();
		return 0;
	}

	private void summerize(Run run) {
			double sum = 0.0;
			foreach(var track in run.tracks) {
				sum += track.tail.weight;
			}
			stdout.flush();

		
	}
}



