[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public abstract class Track : Object{
		public string name;
		public double mass;
		public double charge;
		public double mdm;
		/*Phase space dimensions*/
		public int dimensions;
		public double[] tolerance;
		public double spin_parallel; /*+1 / -1, along/not along the B field*/

		public abstract Vertex create_vertex();
		public abstract Vertex clone_vertex(Vertex source);

		public virtual Vertex create_vertex_with_kinetics(double kinetic, Vector direction) {
			Vertex v = create_vertex();
			double vel = Math.sqrt(2 * kinetic / mass);
			v.velocity = direction.mul(vel);
			return v;
		}

		public double get_kinetic_energy(Vertex? vertex = null) {
			if(vertex == null) vertex = tail;
			return vertex.velocity.norm2() * mass * 0.5;
		}

		public Track parent {get; private set;}

		public weak Run run {get; private set;}
		/*accessed in Evolvution */
		public double length {get; internal set; default = 0.0;}
		/*accessed in Run*/
		public bool terminated {get; set; default = false;}

		internal Evolution evolution;
		internal FreeLengthTable flt;

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

		/**
		 * Start a track.
		 *
		 * head: the head of the track. Track.head will hold a reference to
		 *       this vertex. Track.tail will be a clone of it.
		 *       if the initial part and volume is not specified, the
		 *       method tries to locate the given vertex in the experiment by
		 *       Experiment.locate.
		 */
		public void start(Run run, Vertex head) {
			this.run = run;
			this.head = head;
			tail = clone_vertex(head);
			tail.timestamp = run.timestamp;
			if(tail.part == null || tail.volume == null)
				locate(tail);

			run.tracks.prepend(this);
			run.track_added_notify(this);
			if(tail.part != null) {
				run.active_tracks.prepend(this);
				terminated = false;
			} else {
				terminated = true;
			}
			evolution = new Evolution(this);
			flt = new FreeLengthTable(this);
		}

		public Track fork(Type type, Vertex head) {
			Track the_fork = Track.new(type);
			assert(this.run != null);
			the_fork.start(this.run, head);
			return the_fork;
		}
		public void terminate() {
			terminated = true;
		}
		public void error() {
			terminated = true;
			run.tracks.remove(this);
			run.error_tracks.prepend(this);
		}
		public weak Experiment experiment {get {return run.experiment;}}

		public Vertex tail;
		public Vertex head;

		public double evolve() {
			assert(terminated == false);
			return evolution.evolve();
		}
		public double get_minimal_mfp() {
			double min = double.INFINITY;
			if(tail.part == null) return min;
			foreach(CrossSection section in tail.part.cross_sections) {
				double mfp = 1.0 / (section.density * section.sigma(this, tail));
				if(min > mfp) {
					min = mfp;
				}
			}
			return min;
		}
		public bool locate(Vertex vertex) {
			foreach(weak Part part in experiment.parts) {
				if(part.locate(vertex.position, out vertex.volume)) {
					vertex.part = part;
					return true;
				}
			}
			vertex.part = null;
			return false;
		}
	}
}
