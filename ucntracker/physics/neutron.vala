using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Neutron : Track {
		/*position, velocity, spin = 9*/
		public override int dimensions {get { return 9;}}
		public Neutron() {
			this.name = "this";
			this.mass = 1.675*10e-24/*g*/;
			this.charge = 0.0;
			this.mdm = -9.6623640e-20/*1e-7 J/Tesla*/;
		}
		private class _Vertex: Vertex {
		}
		public override Vertex create_vertex() {
			return new _Vertex();
		}
		public override Vertex clone_vertex(Vertex source) {
			var rt = new _Vertex();
			rt.position = source.position;
			rt.velocity = source.velocity;
			rt.spin = source.spin;
			rt.weight = source.weight;
			rt.timestamp= source.timestamp;
			rt.part = source.part;
			rt.volume = source.volume;
			return rt;
		}
	}
}
