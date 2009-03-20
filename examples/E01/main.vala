using UCNTracker;
Builder builder;
int N_TRACKS = 2000;
public int main(string[] args) {
	UCNTracker.init(ref args);
 	builder = new Builder();
	builder.add_from_file("example-01.xml");

	var experiment = builder.get_object("experiment") as Experiment;
	var cell = builder.get_object("cell") as Part;
	cell.mfp = 1.0;
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
			head.velocity.mul(0.1);
			track.set_vector("in", head.position);
			track.set_vector("in-vel", head.velocity);
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
	};
	cell.transport += (obj, track, leave, enter, transported) => {
		track.set_vector("out", leave.position);
	};
	cell.hit += (obj, track, state) => {
		/*
		stdout.printf("%lf %lf %lf\n", 
		state.vertex.position.x,
		state.vertex.position.y,
		state.vertex.position.z);
		*/
		track.set_double("#scatters", track.get_double("#scatters") + 1.0);

		return ;
		double norm = state.velocity.norm();
		Vector v = Vector(0.0, 0.0, 0.0);
		UCNTracker.Random.dir_3d(out v.x, out v.y, out v.z);
		v.mul(norm);
		state.velocity = v;
		//message("%p %s", track, state.vertex.position.to_string());
	};
	experiment.run();
	return 0;
}
