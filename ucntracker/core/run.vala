using GLib;
using Math;

using UCNTracker.Geometry;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Device {
	public class Run {
		public weak Experiment experiment;
		/* The current time of this run,
		 * individual tracks can be ahead of this stamp 
		 */
		public double time_limit = double.MAX;

		public double timestamp;
		const double dt = 0.2;
		private MainContext context;
		private MainLoop loop;
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
			return track;
		}

		public Track fork_track(Track parent, PType ptype, State fork_state) {
			Track track = new Track.fork(parent, ptype, fork_state);
			tracks.prepend(track);
			if(track.tail.part != null) {
				track.terminated = false;
				active_tracks.prepend(track);
			} else {
				track.terminated = true;
			}
			return track;
		}
		public void terminate_track(Track track) {
			track.terminated = true;
			active_tracks.remove(track);
		}

		public Run(Experiment experiment) {
			this.context = new MainContext();
			this.loop = new MainLoop(context, false);
			this.experiment = experiment;
		}

		public signal void track_motion_notify(Track track, State prev);

		public void run() {
			IdleSource idle = new IdleSource();
			idle.set_callback(run1, null);
			idle.attach(context);
			loop.run();
		}

		private bool run1() {
			if(active_tracks == null || timestamp > time_limit) {
				loop.quit();
				return false;
			}
			double next_t = timestamp + dt;
			foreach(Track track in active_tracks) {
				while(!track.terminated &&
				    track.tail.timestamp < next_t) {
					track.evolve();
				}
			}
			timestamp += dt;
			return true;
		}
	}
}}
