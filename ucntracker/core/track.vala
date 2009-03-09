using GLib;
using Math;

using UCNTracker.Geometry;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Device {
	/* Temporarily move out of Track, to workaround vala bug
	 * REF needed
	 * */
		public struct State {
			public Vertex vertex;
			public weak Part part;
			public weak Volume volume;
			public double timestamp;

			public State(){
				vertex = new Vertex();
			}

			public State.clone(State src) {
				this.vertex = src.vertex.clone();
				this.part = src.part;
				this.volume = src.volume;
				this.timestamp = src.timestamp;
			}
			public void locate_in(Experiment experiment) {
				experiment.locate(vertex, out part, out volume);
			}
		}

	public class Track {
		public weak Run run {get; private set;}

		public PType ptype {get; private set;}
		public Track parent {get; private set;}
		/*accessed in Run*/
		public bool terminated {get; set; default = false;}

		private Evolution evolution;

		private Datalist<void*> data;

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

			tail.vertex = head;
			tail.timestamp = run.timestamp;
			tail.locate_in(experiment);
			evolution = new Evolution(this);
		}

		public Track.fork(Track parent, PType ptype, State state) {
			this.run = parent.run;
			this.experiment = parent.experiment;
			this.parent = parent;
			this.ptype = ptype;

			this.tail = state;
			evolution = new Evolution(this);
		}

		public weak Experiment experiment {get; private set;}

		public State tail;

		public double estimate_distance(State next) {
			/*FIXME: use a parabola*/
			return tail.vertex.position.distance(next.vertex.position);
		}
		public void evolve() {
			assert(terminated == false);
			terminated = evolution.evolve();
			if(terminated)
				run.terminate_track(this);
		}
	}
}
}
