using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Run {
		public weak Experiment experiment;
		/* The current time of this run,
		 * individual tracks can be ahead of this stamp 
		 */
		public double time_limit = double.MAX;

		public bool running = false;
		public double timestamp;
		/* in each run, move all tracks forward at least by 
		 * SYNC_TIME_STEP*/
		public double frame_length = 0.2;

		public Source source {get; set; default = new IdleSource();}

		public List<Track> tracks;
		public List<weak Track> active_tracks;

		public Run(Experiment experiment) {
			this.experiment = experiment;
			this.source.set_callback(run1);
		}

		/**
		 * emitted when a track has moved forward.
		 * */
		public signal void track_motion_notify(Track track, Vertex? prev);
		/**
		 * emitted when the run has moved forward by a time step
		 * */
		public signal void run_motion_notify();
		/**
		 * emitted when a track is created, be it forked or directly created
		 */
		public signal void track_added_notify(Track track);

		private bool run1() {
			if(running == true && 
				(active_tracks == null || timestamp > time_limit)) {
				message("Run finished at %lf", timestamp);
				running = false;
				experiment.finish(this);
				return false;
			}
			if(running == false) {
				experiment.prepare(this);
				running = true;
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
				track.tail.timestamp += sync_t;
			}
			timestamp += frame_length;
			run_motion_notify();
			return true;
		}
	}
}
