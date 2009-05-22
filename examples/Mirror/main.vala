using GLib;
using GL;
using GLU;
using UCNTracker;
using UCNPhysics;
//using Vala.Runtime;
using Math;

private const string GML =
"""
--- 
-!Experiment &experiment
 max_time_step: 0.0001
 objects:
 - !AccelField
    accel: 980.0
    direction: 0, 0, -1
 - !Part &Mirror
    layer: 1
    objects:
    - !Box
       center: 0, 4, 0
       size: 80, 160, 100
    neighbours:
      *Lab: { absorb: 0, diffuse: 0, fermi: 0, reflect: 100 }
 - !Part &Lab
    layer: 0
    objects: 
    - !Ball &ball
       center: 0, 0, 0
       radius: 500
    neighbours: 
      *Mirror: { absorb: 0, diffuse: 0, fermi: 0, reflect: 100 }

...
""";

public class Simulation {
	double received;
	double loss_cell;
	double loss_up_sc;
	double error;
	double energy = 0.0;
	int number_tracks = 1;
	int number_runs = 1;
	bool visual = true;
	Builder builder = new Builder("UCN");
	Gsl.RNG rng = new Gsl.RNG(Gsl.RNGTypes.mt19937);
//	Part guide;
	Experiment experiment;
//	Part disc;
//	Part cell;
	Part mirror;
	Part lab;
	Ball ball;
	Camera camera = new Camera();
	Gtk.Entry entry_energy = new Gtk.Entry();
//	Gtk.Entry entry_field = new Gtk.Entry();
	Gtk.Entry entry_tracks = new Gtk.Entry();
	Gtk.Entry entry_runs = new Gtk.Entry();
	Gtk.CheckButton check_visual = new Gtk.CheckButton.with_label("Visualization");

	public void init() {
		builder.add_from_string(GML);
		experiment = builder.get_object("experiment") as Experiment;
//		guide = builder.get_object("Guide") as Part;
//		disc = builder.get_object("Disc") as Part;
//		cell = builder.get_object("Cell") as Part;
		mirror = builder.get_object("Mirror") as Part;
		lab = builder.get_object("Lab") as Part;
		ball = builder.get_object("ball") as Ball;
		camera.experiment = experiment;
//		double LR = 500;
		experiment.prepare += (ex, run) => {
			if(visual) camera.run = run;
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
			for(int i = 0; i< number_tracks; i++) {
				Track track = Track.new(typeof(Neutron));
				double theta = dist.next(rng);
				double phi = 2.0 * rng.uniform() * 3.14;
				Vector dir = Vector( sin(theta) * cos(phi), cos(theta), sin(theta) * sin(phi));
				energy = v_dist.next(rng) * UNITS.M;
				energy = 0.5 * track.mass * energy * energy;
				Vertex head = track.create_vertex_with_kinetics(energy, dir);
				double x, y, z;
				double LR = ball.radius;
				do {
					x = ( rng.uniform() - 0.5 ) * 2 * LR;
					y = ( rng.uniform() - 0.5 ) * 2 * LR;
					z = ( rng.uniform() - 0.5 ) * 2 * LR;
					head.position = Vector(x, y, z);
					head.weight = 1.0;
//					track.start(run, head);
					experiment.locate(head.position, out head.part, out head.volume);
				} while( head.part == mirror );
				track.start(run, head);
				track.magnetic_helicity = rng.uniform() < 0.5? 1: -1;
			}

			run.time_limit = 50;
			run.frame_length = 0.2;
		};
		experiment.finish += (ex, run) => {
			summerize(run);
			if(number_runs > 0) {
				number_runs--;
				received = 0.0;
				loss_cell = 0.0;
				loss_up_sc = 0.0;
				error = 0.0;
				experiment.add_run().attach();
			}
		};
	}

	private void init_gui() {
		Gtk.Window window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
		Gtk.Box box = new Gtk.VBox(false, 0);
		Gtk.Button button = new Gtk.Button.with_label("go");

		box.pack_start(camera, true, true, 0);
		Gtk.Box hbox = new Gtk.HBox(false, 0);
		box.pack_start(hbox, false, false, 0);

//		hbox.pack_start(entry_energy, false, false, 0);
//		hbox.pack_start(entry_field, false, false, 0);
		hbox.pack_start(entry_tracks, false, false, 0);
		hbox.pack_start(entry_runs, false, false, 0);
		hbox.pack_start(check_visual, false, false, 0);
		hbox.pack_start(button, false, false, 0);

//		entry_energy.text = "400";
//		entry_field.text= "1.0";
		entry_tracks.text= "500";
		entry_runs.text = "8";
		check_visual.set_active(true);
		button.clicked += (btn) => {
//			energy = entry_energy.text.to_double() * 1.0e-9 * UNITS.EV;
			number_tracks = entry_tracks.text.to_int();
			visual = check_visual.get_active();
			number_runs = entry_runs.text.to_int();
//			var field = builder.get_object("Mag") as BarrierField;
//			field.factor = entry_field.text.to_double();
			received = 0.0;
			loss_cell = 0.0;
			loss_up_sc = 0.0;
			error = 0.0;
			experiment.add_run().attach();
		};
		camera.use_solid = false;
		camera.set_size_request(200, 200);
		window.add(box);
		window.show_all();
		window.destroy += Gtk.main_quit;
	}
	public static int main(string[] args) {
		UCNTracker.init(ref args);
		UCNTracker.set_verbose(false);
		UCNTracker.set_absolutely_quiet(true);
		Gtk.init(ref args);
		Simulation sim = new Simulation();
		sim.init();
//		sim.init_physics();
		sim.init_gui();
		Gtk.main();
		return 0;
	}
	private void summerize(Run run) {
			/*
			message("Total tracks %u", run.tracks.length());
			*/
			double sum = 0.0;
			foreach(var track in run.tracks) {
			/*	message("bounces %lf life %lf %s", track.get_double("bounces"), track.tail.timestamp, 
					track.tail.part!=null?track.tail.part.get_name():"NOWHERE");
				*/
				sum += track.tail.weight;
			}
			/*
			message("Error tracks %u", run.error_tracks.length());
			*/
			stdout.printf("Received neutrons: %lf loss-cell: %lf loss-up-sc %lf total weight: %lf\n", received, loss_cell, loss_up_sc, sum);
			stdout.flush();

		
	}
}

