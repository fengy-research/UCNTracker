using UCNTracker;
using Vala.Runtime;
using Math;

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
	Part guide;
	Experiment experiment;
	Part disc;
	Part cell;
	Camera camera = new Camera();
	Gtk.Entry entry_energy = new Gtk.Entry();
	Gtk.Entry entry_field = new Gtk.Entry();
	Gtk.Entry entry_tracks = new Gtk.Entry();
	Gtk.Entry entry_runs = new Gtk.Entry();
	Gtk.CheckButton check_visual = new Gtk.CheckButton.with_label("Visualization");

	public void init() {
		builder.add_from_file("T.yml");
		experiment = builder.get_object("experiment") as Experiment;
		guide = builder.get_object("Guide") as Part;
		disc = builder.get_object("Disc") as Part;
		cell = builder.get_object("Cell") as Part;

		camera.experiment = experiment;
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
				double x = rng.uniform() * 3.3;
				double z = rng.uniform() * 3.3;
				while( x * x + z * z > 3.3 * 3.3) {
					x = rng.uniform();
					z = rng.uniform();
				}
				head.position = Vector(x, 0.0, z);
				head.weight = 1.0;
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
	private void init_physics() {
		guide.transport += (part, track, leave, enter, transported) => {
			assert(enter.part != leave.part);
			var next_name = enter.part.get_name();
			transported = false;
			if(leave.weight < 1e-6 || enter.part == null) {
				track.error();
			} else if (enter.part == disc) {
				transported = true;
				track.terminate();
				received += track.tail.weight;
			} else if(enter.part == cell) {
				transported = false;
				Transport.optic_reflect(part, track, leave, enter, ref transported);
				double weight = leave.weight;
				leave.weight = weight * 0.5;
				enter.weight = weight * 0.5;
				track.fork(typeof(Neutron), enter).terminate();
				loss_cell += enter.weight;
			} else {
				Vector norm = leave.volume.grad(leave.position);
				double f = 8.5e-5;
				double d = 0.01;
				double V = 1.0 * 193.0e-9 * UNITS.EV;

				double bounces = track.get_double("bounces");
				track.set_double("bounces", bounces + 1);
				if(rng.uniform() > d) {
					double E = 0.5 * track.mass * leave.velocity.norm2();
					double cos_s = leave.velocity.direction().dot(norm);
					double Ecos2_s = E * cos_s * cos_s;
					//message("mass = %lg E = %lg E+ = %lg V = %lg cos_s = %lf", track.mass,  E / (UNITS.EV * 1.0), Ecos2_s / (UNITS.EV *1.0), V / (1.0 *UNITS.EV), cos_s);
					double weight = leave.weight;

					if(Ecos2_s < V) {
						Transport.optic_reflect(part, track, leave, enter, ref transported);
						double t = 2.0 * f * Math.sqrt(Ecos2_s/(V - Ecos2_s));
						double r = 1.0 - t;
						//message(" t = %lg r = %lg", t, r);
						leave.weight = weight * r;
						enter.weight = weight * t;
						track.fork(typeof(Neutron), enter).terminate();
						loss_up_sc += enter.weight;
					} else {
						track.terminate();
						loss_up_sc += weight;
					}
				} else {
					Vector v = Vector(0,0,0);
					do {
				//		the new velocity has to be pointing inside
						Gsl.Randist.dir_3d(rng, out v.x,
									out v.y,
									out v.z);
					} while(v.dot(norm) >= -0.01) ;
					leave.velocity = v.mul(leave.velocity.norm());
				}
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
		hbox.pack_start(entry_field, false, false, 0);
		hbox.pack_start(entry_tracks, false, false, 0);
		hbox.pack_start(entry_runs, false, false, 0);
		hbox.pack_start(check_visual, false, false, 0);
		hbox.pack_start(button, false, false, 0);

//		entry_energy.text = "400";
		entry_field.text= "1.0";
		entry_tracks.text= "500";
		entry_runs.text = "8";
		check_visual.set_active(true);
		button.clicked += (btn) => {
//			energy = entry_energy.text.to_double() * 1.0e-9 * UNITS.EV;
			number_tracks = entry_tracks.text.to_int();
			visual = check_visual.get_active();
			number_runs = entry_runs.text.to_int();
			var field = builder.get_object("Mag") as BarrierField;
			field.factor = entry_field.text.to_double();
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
		sim.init_physics();
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

