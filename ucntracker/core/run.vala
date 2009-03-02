using GLib;
using Math;

using UCNTracker.Geometry;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Device {
	public class Run {
		public Experiment experiment;
		/* The current time of this run,
		 * individual tracks can be ahead of this stamp 
		 */
		public double timestamp;
		const double dt = 0.2;
		public List<Track> tracks;
		public List<weak Track> active_tracks;
		public signal void prepare();
		public void run() {
		}
		public void run1() {
			double next_t = timestamp + dt;
			foreach(Track track in active_tracks) {
				while(!track.terminated &&
					track.now.timestamp < next_t) {
				//track.evolve();
				}
			}
		}
		public signal void finish();
	}
}}
