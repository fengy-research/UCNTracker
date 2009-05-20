using UCNTracker;
using UCNPhysics;
using Math;

public class Simulation {
	Experiment experiment;
	Gsl.RNG rng = new Gsl.RNG(Gsl.RNGTypes.mt19937);
	Builder builder = new Builder("UCN");
	Part cell;
	public void init() {
		builder.add_from_file(FileStream.open("geometry.yml", "r"));
		experiment = builder.get_object("experiment") as Experiment;
		cell = builder.get_object("cell") as Part;
		experiment.prepare += (ex, run) => {
			Track track = Track.new(typeof(Neutron));
			Vertex head = track.create_vertex();
			head.position = Vector(0, 0.1, 0);
			head.velocity = Vector(0, 1, 0);
			track.start(run, head);
			
			run.time_limit = 100;
		};
		experiment.finish += (ex, run) => {
			Gtk.main_quit();
		};
	}
	void run() {
		experiment.add_run().attach();
	}
	public static int main(string[] args) {
		UCNTracker.init(ref args);
		Gtk.init(ref args);
		Simulation sim = new Simulation();
		sim.init();
		sim.run();
		Gtk.main();
		return 0;
	}
}
