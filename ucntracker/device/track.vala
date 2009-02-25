using GLib;
using Math;

using UCNTracker.Geometry;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Device {
	public class Track {
		public weak Run run;

		public PType ptype;
		public Track parent;

		/** 
		 * Current time of the stamp
		 * Can be ahead of the timestamp of the run 
		 * 
		 **/

		public double timestamp;
		/**
		 * in units of mean_free_paths, always.
		 */
		public double free_path_length;

		public Queue<Vertex> vertices = new Queue<Vertex>();
		public Vertex current { get { return vertices.peek_tail();}}

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
			this.vertices.push_tail(head);
			
			experiment.locate(head, out this.current_part, out this.current_volume);

			run.active_tracks.prepend(this);
			run.tracks.prepend(this);
		}
		public Track fork(Run run, PType ptype, Vertex head) {
			Track child = new Track(run, ptype, head);
			child.parent = this;
			return child;
		}

		public void append_vertex(Vertex vertex) {
			free_path_length += current.position.distance(vertex.position)
					/ current_part.mean_free_path(current);
			vertices.push_tail(vertex);
		}
		private weak Experiment experiment;
		private weak Part current_part;
		private weak Volume current_volume;

		public void integrate(double dt, out Vertex next) {
			next = current.copy();
			next.position.x += next.velocity.x * dt;
			next.position.y += next.velocity.z * dt;
			next.position.z += next.velocity.z * dt;
		}

		public void evolve(double end_time) {
			assert(_terminated == false);
			double dt = end_time - timestamp;
			/* If we are already in advance */
			if(dt < 0.0) return;

			Vertex next;
			integrate(dt, out next);

			weak Part next_part;
			weak Volume next_volume;

			experiment.locate(next, out next_part, out next_volume);
			if(next_part == null) {
				/* if we go out of the world, terminate*/
				this.terminated = true;
				return;
			}
			Vector intersection;
			double r;
			bool current_volume_changed = true;
			if(current_volume.intersect(current.position, next.position, out intersection, out r)) {
				/* Leaves */
				Vertex leaves = current.copy();
				leaves.position = intersection;
				/*TODO: emit a signal and wait for the result.*/
				append_vertex(leaves);
				if(current_volume_changed) {
					current_part = next_part;
					current_volume = next_volume;
				}
				evolve(end_time);
				return;
			}
			if(next_volume != null && next_volume != current_volume) {
				if(next_volume.intersect(current.position, next.position, out intersection, out r)) {
					/* enters */
					Vertex enters = current.copy();
					enters.position = intersection;
					/*TODO: emit a signal and wait for the result.*/
					if(current_volume_changed) {
						current_part = next_part;
						current_volume = next_volume;
					}
					evolve(end_time);
					}
			}
			append_vertex(next);
			timestamp = end_time;
		}
	}
}
}
