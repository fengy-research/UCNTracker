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
			public State(){}
			public void locate_in(Experiment experiment) {
				experiment.locate(vertex, out part, out volume);
			}
		}
	public class Track {
		public weak Run run;

		public PType ptype;
		public Track parent;

		/**
		 * in units of mean_free_paths, always.
		 */
		public double free_path_length;


		public bool terminated = false;
		public Track(Run run, PType type, Vertex head) {
			this.run = run;
	   		this.experiment = run.experiment;
			this.ptype = type;

			now.vertex = head;
			now.timestamp = run.timestamp;
			now.locate_in(experiment);

		}
		public Track.fork(Track parent, PType ptype, Vertex head) {
			this.run = parent.run;
	   		this.experiment = parent.experiment;
			this.parent = parent;
			this.ptype = ptype;

			now.vertex = head;
			now.timestamp = parent.now.timestamp;
			now.locate_in(experiment);
		}

		public void acc_free_path(State next) {
			free_path_length += next.vertex.position.distance(now.vertex.position)
					/ now.part.mean_free_path(now.vertex);
		}
		private weak Experiment experiment;

		public State now;
		private State next;

		public void integrate(ref State future, double dt) {
			future.vertex = now.vertex;
			Vector vel = now.vertex.velocity;
			future.vertex.position.x += vel.x * dt;
			future.vertex.position.y += vel.y * dt;
			future.vertex.position.z += vel.z * dt;
			future.vertex.velocity = now.vertex.velocity;
			future.timestamp = now.timestamp + dt;
		}
		public const double TIME_STEP_SIZE = 1.0;
		public void integrate_adaptive(ref State future, out double dt) {
			dt = TIME_STEP_SIZE;
			integrate(ref future, dt);
		}
		public Vector cfunc(double dt) {
			State future = State();
			integrate(ref future, dt);
			return future.vertex.position;
		}

		public void evolve() {
			assert(terminated == false);

			if(now.part == null) {
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

			if(now.volume == next.volume) {
				acc_free_path(next);
				/*FIXME: use mfp!*/
				now.part.hit(this, now.vertex);
				now = next;
				return;
			}



			double dt_leave;
			/* assign a value to shut up the compiler,
			 * dt_enter is used only if is_enter is true, which means
			 * out dt_enter is excuted. */
			double dt_enter = 0.0;

			bool is_leave = now.volume.intersect(cfunc, 0, dt, out dt_leave);
			bool is_enter = (next.part != null) 
				&& next.volume.intersect(cfunc, 0, dt, out dt_enter);

			State leave = State();
			State enter = State();
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
			now.part.transport(this, next.part, leave.vertex, enter.vertex);
			acc_free_path(leave);
			now = leave;
			return;
		}
	}
}
}
