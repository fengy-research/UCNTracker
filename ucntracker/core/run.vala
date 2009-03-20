using GLib;
using Math;

using UCNTracker.Geometry;
using UCNTracker.Device;
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
		public const double SYNC_TIME_STEP = 0.2;

		public Source source {get; set; default = new IdleSource();}

		public List<Track> tracks;
		public List<weak Track> active_tracks;

		public Track add_track(PType ptype, Vertex head) {
			Track track = new Track(this, ptype, head);
			tracks.prepend(track);
			if(track.tail.part != null) {
				track.terminated = false;
				active_tracks.prepend(track);
			} else {
				track.terminated = true;
			}
			track_added_notify(track);
			return track;
		}

		public Track fork_track(Track parent, PType ptype, Vertex fork_state) {
			Track track = new Track.fork(parent, ptype, fork_state);
			tracks.prepend(track);
			if(track.tail.part != null) {
				track.terminated = false;
				active_tracks.prepend(track);
			} else {
				track.terminated = true;
			}
			track_added_notify(track);
			return track;
		}
		public void terminate_track(Track track) {
			track.terminated = true;
			active_tracks.remove(track);
		}

		public Run(Experiment experiment) {
			this.experiment = experiment;
			this.source.set_callback(run1, null);
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
				message("%lf %lf", timestamp, time_limit);
				running = false;
				experiment.finish(this);
				return false;
			}
			if(running == false) {
				experiment.prepare(this);
				running = true;
			}
			double next_t = timestamp + SYNC_TIME_STEP;
			foreach(Track track in active_tracks) {
				while(!track.terminated &&
				    track.tail.timestamp < next_t) {
					track.evolve();
				}
			}
			timestamp += SYNC_TIME_STEP;
			run_motion_notify();
			return true;
		}
	}
}
