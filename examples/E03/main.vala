using UCNTracker;
using UCNPhysics;
using Math;

public class Simulation :VisSimulation {
	Experiment experiment;
	Part cell;
	public void init() {
		experiment = builder.get_object("experiment") as Experiment;
		cell = get_part("cell") as Part;
		prepare += (ex, run) => {
			Track track = Track.new(typeof(Neutron));
			Vertex head = track.create_vertex();
			head.position = Vector(0, 0.1, 0);
			head.velocity = Vector(0, 1, 0);
			track.start(run, head);
			
			run.time_limit = 100;
		};
	}
	public static int main(string[] args) {
		UCNTracker.init(ref args);
		Gtk.init(ref args);
		Simulation sim = new Simulation();
		sim.init_from_file("geometry.yml");
		sim.run();
		Gtk.main();
		return 0;
	}
}
