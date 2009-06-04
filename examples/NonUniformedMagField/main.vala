using GLib;
using GL;
using GLU;
using UCNTracker;
using UCNPhysics;
using Math;

private const string YML = 
"""
--- !Experiment
 max_time_step: 0.0001
 objects:
 - !AccelField &G
    accel: 980.0
    direction: 0, 0, -1

 - !CustomField &Mag
   volumes: [ *box ]

 - !Part &Lab
    layer: 0
    volumes: 
    - !Ball &ball
       center: 0, 0, 0
       radius: 500

 - !Part &Container
    layer: 1
    volumes:
    - !Box &box
      center: 0, 0, 0
      size: 100, 100, 100
    neighbours:
    *Lab: { reflect: 100 }

...

""";

public class Simulation : VisSimulation {
	double received;
	double loss_cell;
	double loss_up_sc;
	double error;
	double energy = 0.0;
	int number_tracks = 1;
	int number_runs = 1;
	bool visual = true;
	CustomField MagF;
	AccelField GF;
	Part Lab;
	Part Ctn;
	Box box;
	Gtk.Entry entry_energy = new Gtk.Entry();
	Gtk.Entry entry_field = new Gtk.Entry();
	Gtk.Entry entry_tracks = new Gtk.Entry();
	Gtk.Entry entry_runs = new Gtk.Entry();
	Gtk.CheckButton check_visual = new Gtk.CheckButton.with_label("Visualization");
	
	public override void init() throws GLib.Error {
		base.init();
		MagF = builder.get_object("Mag") as CustomField;
		GF = builder.get_object("G") as AccelField;
		Lab = get_part("Lab");
		Ctn = get_part("Container");
		box = get_volume("box") as Box;
		MagF.function = (track, Q, dQ) => {
			double B = Math.pow(Math.pow(10 - 0.1 * Q.position.z, 2) + 0.0025 * (Math.pow(Q.position.x, 2) + Math.pow(Q.position.y, 2)), 0.5) * UNITS.TESLA;
			dQ.spin_precession = -B;
			dQ.velocity.x += track.spin_parallel * 0.0025 * Q.position.x / ( B * track.mass );
			dQ.velocity.y += track.spin_parallel * 0.0025 * Q.position.y / ( B * track.mass );
			dQ.velocity.z += track.spin_parallel * ( -0.1 ) * ( 10 - 0.1 * Q.position.z ) / ( B * track.mass );
			return true;
		};
			
		prepare += (ex, run) => {
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
			}

			run.time_limit = 200;
			run.frame_length = 0.05;
		};
		finish += (ex, run) => {
			summerize(run);
			if(number_runs > 0) {
				number_runs--;
				received = 0.0;
				loss_cell = 0.0;
				loss_up_sc = 0.0;
				error = 0.0;
				add_run().attach();
			}
		};
		init_gui();
	}

	private void init_gui() {
		Gtk.Button button = new Gtk.Button.with_label("go");
		Gtk.Box hbox = new Gtk.HBox(false, 0);
		widget_box.pack_start(hbox, false, false, 0);

//		hbox.pack_start(entry_energy, false, false, 0);
		hbox.pack_start(entry_field, false, false, 0);
		hbox.pack_start(entry_tracks, false, false, 0);
		hbox.pack_start(entry_runs, false, false, 0);
		hbox.pack_start(check_visual, false, false, 0);
		hbox.pack_start(button, false, false, 0);

//		entry_energy.text = "400";
		entry_field.text= "1.0";
		entry_tracks.text= "10";
		entry_runs.text = "10";
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
			add_run().attach();
		};
	}

	public static int main(string[] args) {
		UCNTracker.init(ref args);
		UCNTracker.set_verbose(false);
		UCNTracker.set_absolutely_quiet(true);
		Simulation sim = new Simulation();
		sim.init_from_file("T.yml");
		sim.run(false, false);
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
//			stdout.printf("Magnetic spin precession: %lf\n", Math.fmod(track.tail.spin_precession - track.head.spin_precession, 2 * 3.14));
			}
			/*
			message("Error tracks %u", run.error_tracks.length());
			*/
			stdout.printf("Received neutrons: %lf loss-cell: %lf loss-up-sc %lf total weight: %lf\n", received, loss_cell, loss_up_sc, sum);
			stdout.flush();

		
	}
}


