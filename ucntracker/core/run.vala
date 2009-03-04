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
		public double timestamp;
		const double dt = 0.2;
		public List<Track> tracks;
		public List<weak Track> active_tracks;
		public Track add_track(PType ptype, Vertex head) {
			Track track = new Track(this, ptype, head);
			tracks.prepend(track);
			if(track.now.part != null) {
				track.terminated = false;
				active_tracks.prepend(track);
			} else {
				track.terminated = true;
			}
			return track;
		}
		public Track fork_track(Track parent, PType ptype, Vertex head) {
			Track track = new Track.fork(parent, ptype, head);
			tracks.prepend(track);
			if(track.now.part != null) {
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
			this.experiment = experiment;
		}
		public void run() {
			while(active_tracks != null) {
			//	message("Number of active tracks: %u", active_tracks.length());
				run1();
			}
		}
		private void run1() {
			double next_t = timestamp + dt;
			foreach(Track track in active_tracks) {
				while(!track.terminated &&
				    track.now.timestamp < next_t) {
					track.evolve();
				}
			}
			timestamp += dt;
		}
	}
}}
