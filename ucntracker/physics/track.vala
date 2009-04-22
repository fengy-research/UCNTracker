using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public abstract class Track : Object{
		public string name;
		public double mass;
		public double charge;
		public double mdm;

		/*Phase space dimensions*/
		public virtual int dimensions {get {return 9;}}
		public abstract Vertex create_vertex();
		public abstract Vertex clone_vertex(Vertex source);

		public Track parent {get; private set;}

		public weak Run run {get; private set;}
		/*accessed in Evolvution */
		public double length {get; internal set; default = 0.0;}
		/*accessed in Run*/
		public bool terminated {get; set; default = false;}

		private Evolution evolution;

		private Datalist<void*> data;

		public double estimate_distance(Vertex next) {
			/*FIXME: use a parabola*/
			return tail.position.distance(next.position);
		}

		public void* get_pointer(string name) {
			return data.get_data(name);
		}
		public void steal_pointer(string name) {
			data.remove_no_notify(name);
		}
		public void set_pointer(string name, void* pointer, DestroyNotify? dn = null) {
			data.set_data_full(name, pointer, dn);
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

		public new static Track new(Type type) {
			assert(type.is_a(typeof(Track)));
			return Object.new(type) as Track;
		}

		public void start(Run run, Vertex head) {
			this.run = run;
			this.experiment = run.experiment;
			tail = clone_vertex(head);
			tail.timestamp = run.timestamp;
			if(tail.part == null || tail.volume == null)
				experiment.locate(tail.position, out tail.part, out tail.volume);

			run.tracks.prepend(this);
			run.track_added_notify(this);
			if(tail.part != null) {
				run.active_tracks.prepend(this);
				terminated = false;
			} else {
				terminated = true;
			}
			evolution = new Evolution(this);
		}

		public Track fork(Type type, Vertex head) {
			Track the_fork = Track.new(type);
			assert(this.run != null);
			the_fork.start(this.run, head);
			return the_fork;
		}
		public void terminate() {
			terminated = true;
			run.active_tracks.remove(this);
		}
		public weak Experiment experiment {get; private set;}

		public Vertex tail;

		public void evolve() {
			assert(terminated == false);
			evolution.evolve();
		}
	}
}
