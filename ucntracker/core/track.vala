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
			public void locate_in(Experiment experiment) {
				experiment.locate(vertex, out part, out volume);
			}
		}
	public class Track {
		public weak Run run;

		public PType ptype;
		public Track parent;
		private Datalist<void*> data;
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
		public bool terminated = false;
		public Track(Run run, PType type, Vertex head) {
			this.run = run;
	   		this.experiment = run.experiment;
			this.ptype = type;

			tail.vertex = head;
			tail.timestamp = run.timestamp;
			tail.locate_in(experiment);
		}
		public Track.fork(Track parent, PType ptype, Vertex head) {
			this.run = parent.run;
	   		this.experiment = parent.experiment;
			this.parent = parent;
			this.ptype = ptype;

			tail.vertex = head;
			tail.timestamp = parent.tail.timestamp;
			tail.locate_in(experiment);
		}

		public double distance_to (Vertex v) {
			/*FIXME: use S.G's suggestion, parabolic appr.*/
			return v.position.distance(tail.vertex.position);
		}
		private weak Experiment experiment;

		public State tail;
		private State next;

		public void integrate(ref State future, double dt) {
			future.vertex = tail.vertex.clone();
			Vector vel = tail.vertex.velocity;
			future.vertex.position.x += vel.x * dt;
			future.vertex.position.y += vel.y * dt;
			future.vertex.position.z += vel.z * dt;
			future.vertex.velocity = tail.vertex.velocity;
			future.timestamp = tail.timestamp + dt;
		}
		public const double TIME_STEP_SIZE = 1.0;
		public void integrate_adaptive(ref State future, out double dt) {
			dt = TIME_STEP_SIZE;
			integrate(ref future, dt);
		}
		public Vector cfunc(double dt) {
			State future = State();
			integrate(ref future, dt);
			/*
			message("dt = %lf tail.position = %lf %lf %lf vertex.position = %lf %lf %lf",
					dt,	
					tail.vertex.position.x,
					tail.vertex.position.y,
					tail.vertex.position.z,
					future.vertex.position.x,
					future.vertex.position.y,
					future.vertex.position.z);
					*/

			return future.vertex.position;
		}

		public void evolve() {
			assert(terminated == false);

			if(tail.part == null) {
				terminated = false;
				run.terminate_track(this);
				return;
			}
			double dt;
			State next = State();
			integrate_adaptive(ref next, out dt);
			message("next: %lf %lf %lf", 
					next.vertex.position.x,
					next.vertex.position.y,
					next.vertex.position.z);
			next.locate_in(experiment);

			if(tail.volume == next.volume) {
				tail.part.hit(this, next.timestamp, next.vertex);
				tail = next;
				return;
			}



			double dt_leave;
			/* assign a value to shut up the compiler,
			 * dt_enter is used only if is_enter is true, which means
			 * out dt_enter is excuted. */
			double dt_enter = 0.0;

			bool is_leave = tail.volume.intersect(cfunc, 0, dt, out dt_leave);
			bool is_enter = (next.part != null) 
				&& next.volume.intersect(cfunc, 0, dt, out dt_enter);

			State leave = State();
			State enter = State();
			//message("%s %s", is_leave.to_string(), is_enter.to_string());
			if(is_leave && is_enter) {
				integrate(ref leave, dt_leave);
				integrate(ref enter, dt_enter);
			}
			if(is_leave) {
				integrate(ref leave, dt_leave);
				enter = leave;
			}
			if(is_enter) {
				integrate(ref enter, dt_enter);
				leave = enter;
			}
			tail.part.hit(this, dt_leave + tail.timestamp, leave.vertex);
			leave.part = tail.part;
			leave.volume = tail.volume;
			tail = leave;
			tail.part.transport(this, next.part, leave.vertex, enter.vertex);
			tail.part.hit(this, dt_leave + tail.timestamp, leave.vertex);
			return;
		}
	}
}
}
