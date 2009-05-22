[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Run {
		public weak Simulation sim;
		/* The current time of this run,
		 * individual tracks can be ahead of this stamp 
		 */
		public double time_limit = double.MAX;

		public Experiment experiment {
			get { return sim.experiment; }
		}

		public bool running = false;
		public double timestamp = 0.0;
		/* in each run, move all tracks forward at least by 
		 * SYNC_TIME_STEP*/
		public double frame_length = 0.2;

		public List<Track> tracks;
		public List<Track> error_tracks;
		public List<weak Track> active_tracks;

		private uint source_id = 0;
		private MainContext context = null;
		public Run(Simulation sim) {
			this.sim = sim;
		}

		/**
		 * Attach the run to a main context, so that it will be
		 * scheduled by GLib main loop.
		 *
		 * context: the main context, null for the default context
		 *
		 */
		public void attach(MainContext? context = null) {
			if(source_id != 0) {
				Source.remove(source_id);
			}
			this.context = context;
			IdleSource source = new IdleSource();
			source.set_callback(run1);
			source_id = source.attach(context);
		}
		/**
		 * Stop a simulation run by marking all tracks as terminated.
		 */
		public void stop() {
			foreach(Track track in tracks) {
				active_tracks.remove(track);
			}
			running = false;
		}
		/**
		 * Pause a simulation run by detaching the run from the
		 * main context.
		 */
		public void pause() {
			if(source_id != 0) {
				Source.remove(source_id);
				source_id = 0;
			}
			running = false;
		}
		/**
		 * Continue the a simulation run by re-attaching the run
		 * to the context.
		 *
		 * If not paused, this function do nothing.
		 */
		public void @continue() {
			if(source_id == 0) {
				IdleSource source = new IdleSource();
				source.set_callback(run1);
				source_id = source.attach(context);
			} else {
				/* do nothing*/
			}
		}
		/**
		 * emitted when a track has moved forward.
		 * */
		public signal void track_motion_notify(Track track, Vertex? prev);
		/**
		 * emitted when the run has moved forward by a frame.
		 * */
		public signal void run_motion_notify();
		/**
		 * emitted when a track is created, be it forked or directly created
		 */
		public signal void track_added_notify(Track track);

		private bool run1() {
			if(MainContext.current_source().is_destroyed()) return false;
			if(running == true && 
				(active_tracks == null || timestamp > time_limit)) {
				debug("Run finished at %lf", timestamp);
				running = false;
				sim.finish(this);
				return false;
			}
			if(running == false) {
				running = true;
				run_motion_notify();
			}
			double next_t = timestamp + frame_length;
			/* This part of code is misterious.
			 * It is accumulates the (very small) time increment to a 
			 * zero-initialized value dt,
			 * then add compare dt to the expected frame sync time step sync_t
			 *
			 * sync_t is not always what we had in frame sync time because
			 * each individual track can be a little bit beyond or behind
			 * this frame length as constrained by the integrator.
			 * */
			foreach(Track track in active_tracks) {
				double dt = 0;
				double sync_t = next_t - track.tail.timestamp;
				while(!track.terminated &&
				    dt < sync_t) {
					dt+= track.evolve();
				}
				track.tail.timestamp += dt;
			}
			/* FIXME: Loop over the active_tracks ONLY.
			 * The total number of tracks is going to be huge.
			 *
			 * */
			foreach(Track track in tracks) {
				if(track.terminated) {
					active_tracks.remove(track);
				}
			}
			foreach(Track track in error_tracks) {
				active_tracks.remove(track);
			}
			timestamp += frame_length;
			debug ("one frame ends: %lf tracks %u", timestamp, active_tracks.length());
			run_motion_notify();
			return true;
		}
	}
}
