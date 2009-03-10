using UCNTracker;
using UCNTracker.Device;
using UCNTracker.Geometry;
Builder builder;
double MFP = 3.0;
int N_TRACKS = 20000;
public int main(string[] args) {
	UCNTracker.init(ref args);
 	builder = new Builder();
	builder.add_from_file("example-01.xml");

	var experiment = builder.get_object("experiment") as Experiment;
	var cell = builder.get_object("cell") as Part;
	experiment.prepare += (obj, run) => {
		var volume = builder.get_object("cellVolume") as Volume;
		for(int i = 0; i < N_TRACKS; i++) {
			Vertex head = new Vertex();
			head.position = volume.sample(true);
			Vector v = Vector(0.0, 0.0, 0.0);
			UCNTracker.Random.dir_3d(out v.x, out v.y, out v.z);
			head.velocity = v;
			head.weight = 1.0;
			var track = run.add_track(PType.neutron, head);
			head.velocity.mul(10);
			track.set_vector("in", head.position);
		}
	};
	experiment.finish += (obj, run) => {
		foreach (Track track in run.tracks) {
			Vector @in = track.get_vector("in");
			Vector @out = track.get_vector("out");

			stdout.printf("%s %s %lf %lf\n", 
				@in.to_string(),
				@out.to_string(),
				track.get_double("length"),
				track.get_double("#scatters")
				);
		}
	};
	cell.transport += (obj, track, leave, enter, transported) => {
		track.set_vector("out", leave.vertex.position);
	};
	cell.hit += (obj, track, state, scattered) => {
		/*
		stdout.printf("%lf %lf %lf\n", 
		state.vertex.position.x,
		state.vertex.position.y,
		state.vertex.position.z);
		*/
		double length = track.get_double("length");
		double r = UCNTracker.Random.uniform();
		double dl = track.estimate_distance(state);
		double dP = Math.exp( -length / MFP) - Math.exp((-length - dl)/MFP);
		bool scatter = false;
		if(r < dP) {
			scatter = true;	
		}
		length += dl;
		track.set_double("length", length);
		if(scatter) {
			track.set_double("#scatters", track.get_double("#scatters") + 1.0);
			double norm = state.vertex.velocity.norm();
			Vector v = Vector(0.0, 0.0, 0.0);
			UCNTracker.Random.dir_3d(out v.x, out v.y, out v.z);
			v.mul(norm);
			state.vertex.velocity = v;
			*scattered = true;
			message("%p %s", track, state.vertex.position.to_string());
		}
	};
	experiment.run();
	return 0;
}
