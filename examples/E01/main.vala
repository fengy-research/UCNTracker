using UCNTracker;
using UCNPhysics;
Builder builder;

int N_TRACKS = 1;
public class Simulation {
	
	Experiment experiment;
	Part cell;
	CrossSection up;
	CrossSection down;
	private void init() {
 		builder = new Builder("UCN");
		builder.add_from_file(FileStream.open("geometry.yml", "r"));
		experiment = builder.get_object("Experiment") as Experiment;
		cell = builder.get_object("Cell") as Part;
		up = builder.get_object("up") as CrossSection;
		down = builder.get_object("down") as CrossSection;
		experiment.prepare += (obj, run) => {
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
		experiment.finish += (obj, run) => {
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
		/*
		cell.hit += (obj, track, state) => {
			stdout.printf("%lf %lf %lf\n", 
			state.vertex.position.x,
			state.vertex.position.y,
			state.vertex.position.z);
			track.set_double("#scatters", track.get_double("#scatters") + 1.0);

			return ;
			double norm = state.velocity.norm();
			Vector v = Vector(0.0, 0.0, 0.0);
			UCNTracker.Random.dir_3d(out v.x, out v.y, out v.z);
			v.mul(norm);
			state.velocity = v;
			//message("%p %s", track, state.vertex.position.to_string());
		};*/
		
		
	}
	public void run() {
		experiment.run();
		
	}
	public static int main(string[] args) {
		UCNTracker.init(ref args);
		UCNTracker.set_verbose(true);
		Simulation sim = new Simulation();
		sim.init();
		sim.run();
		return 0;

	}
}
