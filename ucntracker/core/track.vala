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
			public void locate(Experiment experiment) {
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


		private bool _terminated = false;
		public bool terminated { get { return _terminated;}
		set { 
			_terminated = value;
			if(value == false)
			run.active_tracks.remove(this);
			else /*reactivating a track, which should not likely happen*/
			run.active_tracks.prepend(this);
		}
		}

		public Track(Run run, PType type, Vertex head) {
			this.run = run;
	   		this.experiment = run.experiment;
			this.ptype = type;

			now.vertex = head;
			now.timestamp = run.timestamp;
			now.locate(experiment);

			if(this.now.part != null) {
				run.active_tracks.prepend(this);
			} else {
				this._terminated = true;
			}
			run.tracks.prepend(this);
		}
		public Track fork(Run run, PType ptype, Vertex head) {
			Track child = new Track(run, ptype, head);
			child.parent = this;
			return child;
		}

		public void acc_free_path(State next) {
			free_path_length += next.vertex.position.distance(now.vertex.position)
					/ now.part.mean_free_path(now.vertex);
		}
		private weak Experiment experiment;

		public State now;
		private State next;

		public void integrate(ref State future, double dt) {
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
			assert(_terminated == false);

			double dt;
			State next = State();
			integrate_adaptive(ref next, out dt);
			next.locate(experiment);

			if(next.part == null) {
				/* if we go out of the world, terminate*/
				this.terminated = true;
				return;
			}

			if(now.volume == next.volume) {
				acc_free_path(next);
				now = next;
				return;
			}


			double dt_leave;
			double dt_enter;

			bool is_leave = now.volume.intersect(cfunc, 0, dt, out dt_leave);
			bool is_enter = next.volume.intersect(cfunc, 0, dt, out dt_enter);

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
