using GLib;
using Math;

using UCNTracker.Geometry;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Device {
	public class Track {
		public PType ptype;
		public Node<Track> node;
		public Experiment experiment;
		public Track parent;
		public Queue<Vertex> vertices = new Queue<Vertex>();
		public Vertex current { get { return vertices.peek_tail();}}
		public bool terminated = false;
		public double free_path_length;
		public Track(PType type, Vertex head) {
			this.ptype = type;
			this.vertices.push_tail(head);
		}
		public Track fork(PType ptype, Vertex head) {
			Track child = new Track(ptype, head);
			return child;
		}
		public void evolve() {

		}
	}
}
}
