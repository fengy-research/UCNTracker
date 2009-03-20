using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Track {
		public weak Run run {get; private set;}

		public PType ptype {get; private set;}
		public Track parent {get; private set;}
		/*accessed in Evolvution */
		public double length {get; internal set; default = 0.0;}
		/*accessed in Run*/
		public bool terminated {get; set; default = false;}

		private Evolution evolution;

		private Datalist<void*> data;

		public const int history_length = 100;

		public Queue<Vertex> history = new Queue<Vertex>();

		public double estimate_distance(Vertex next) {
			/*FIXME: use a parabola*/
			return tail.position.distance(next.position);
		}

		public void set_vector(string name, Vector val) {
			Vector * pointer = (Vector*) data.get_data(name);
			if(pointer == null) {
				pointer = new Vector[1];
				data.set_data_full(name, pointer, g_free);
			}
			*pointer = val;
		}
		public Vector get_vector(string name) {
			Vector * pointer = (Vector*)data.get_data(name);
			if(pointer != null) return *pointer;
			return Vector(0.0, 0.0, 0.0);
		}
		public void set_double(string name, double val) {
			double* pointer = (double*)data.get_data(name);
			if(pointer == null) {
				pointer = new double[1];
				data.set_data_full(name, pointer, g_free);
			}
			*pointer = val;
		}

		public double get_double(string name) {
			double * pointer = (double*)data.get_data(name);
			if(pointer != null) return *pointer;	
			return 0.0;
		}

		public Track(Run run, PType type, Vertex head) {
			this.run = run;
			this.experiment = run.experiment;
			this.ptype = type;

			tail = head.clone();
			tail.timestamp = run.timestamp;
			tail.locate_in(experiment);
			evolution = new Evolution(this);
		}

		public Track.fork(Track parent, PType ptype, Vertex head) {
			this.run = parent.run;
			this.experiment = parent.experiment;
			this.parent = parent;
			this.ptype = ptype;

			this.tail = head.clone();
			evolution = new Evolution(this);
		}

		public weak Experiment experiment {get; private set;}

		public Vertex tail;

		public void evolve() {
			assert(terminated == false);
			evolution.evolve();
		}
	}
}
