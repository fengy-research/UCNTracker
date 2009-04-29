using UCNTracker;
using Vala.Runtime;
using Math;
Builder builder;
Camera camera;
Gsl.RNG rng;

double received;
double loss;
double error;
public int main(string[] args) {
	UCNTracker.init(ref args);
	Gtk.init(ref args);
	builder = new Builder();
	builder.add_from_file("T.yml");

	rng = new Gsl.RNG(Gsl.RNGTypes.mt19937);
	var experiment = builder.get_object("experiment") as Experiment;
	received = 0.0;
	loss = 0.0;
	error = 0.0;
	experiment.prepare += (ex, run) => {
//		camera.run = run;
		message("prepare");
		var dist = new UCNTracker.Randist.PDFDist();
		dist.left = 0;
		dist.right = 1.57;
		dist.pdf = (x) => {return Math.pow(Math.cos(x), 2.8);};
		dist.init();
		for(int i = 0; i< 400; i++) {
			Track track = Track.new(typeof(Neutron));
			double theta = dist.next(rng);
			double phi = 2.0 * rng.uniform() * 3.14;
			Vector dir = Vector( sin(theta) * cos(phi), cos(theta), sin(theta) * sin(phi));
			//Vector dir = Vector(0, 0.707, 0.707);
			Vertex head = track.create_vertex_with_kinetics(
				500e-9 * UNITS.EV, dir);
			double x = rng.uniform() * 4.88696;
			double z = rng.uniform() * 4.88696;
			while( x * x + z * z > 4.886 * 4.885) {
				x = rng.uniform();
				z = rng.uniform();
			}
			head.position = Vector(x, 30.48, z);
			head.weight = 1.0;
			track.start(run, head);
		}
		/* A neutron outside of the guide, showing the effects of the gravity.
		var track = Track.new(typeof(Neutron));
		Vertex head = track.create_vertex_with_kinetics(500e-9 *UNITS.EV, Vector(0, 1, 0));
		head.position = Vector( 8, 0, 0);
		track.start(run, head);
		*/
		run.time_limit = 200;
		run.frame_length = 0.2;
		run.attach();
	};


	experiment.finish += (ex, run) => {
		message("run finished");
		summerize(run);
	};
	var guide = builder.get_object("Guide") as Part;
	guide.transport += (part, track, leave, enter, transported) => {
		assert(enter.part != leave.part);
		*transported = false;
		if(leave.weight < 1e-6 || enter.part == null) {
			track.error();
		} else if (enter.part.get_name() == "Disc") {
			*transported = true;
			track.terminate();
			received += track.tail.weight;
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
				message("mass = %lg E = %lg E+ = %lg V = %lg cos_s = %lf", track.mass,  E / (UNITS.EV * 1.0), Ecos2_s / (UNITS.EV *1.0), V / (1.0 *UNITS.EV), cos_s);
				double weight = leave.weight;

				if(Ecos2_s < V) {
					part.optic_reflect(part, track, leave, enter, transported);
					double t = 2.0 * f * Math.sqrt(Ecos2_s/(V - Ecos2_s));
					double r = 1.0 - t;
					message(" t = %lg r = %lg", t, r);
					leave.weight = weight * r;
					enter.weight = weight * t;
					track.fork(typeof(Neutron), enter).terminate();
					loss += enter.weight;
				} else {
					track.terminate();
					loss += weight;
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


	camera = new Camera();
	camera.use_solid = false;
	camera.experiment = experiment;

	camera.set_size_request(200, 200);
	Gtk.Window window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
	Gtk.Box box = new Gtk.VBox(false, 0);
	Gtk.Button button = new Gtk.Button.with_label("go");
	box.pack_start(camera, true, true, 0);
	box.pack_start(button, false, false, 0);

	button.clicked += (btn) => {
		var e = builder.get_object("experiment") as Experiment;
		e.add_run();
	};
	window.add(box);
	window.show_all();
	window.destroy += Gtk.main_quit;


	Gtk.main();
	return 0;
}

private void summerize(Run run) {
		message("Total tracks %u", run.tracks.length());
		double sum = 0.0;
		foreach(var track in run.tracks) {
			message("bounces %lf life %lf %s", track.get_double("bounces"), track.tail.timestamp, 
				track.tail.part!=null?track.tail.part.get_name():"NOWHERE");
			sum += track.tail.weight;
		}
		message("Error tracks %u", run.error_tracks.length());
		message("Received neutrons: %lf loss: %lf, total weight: %lf", received, loss, sum);
	
}
