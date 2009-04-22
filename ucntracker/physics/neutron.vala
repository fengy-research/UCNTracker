using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Neutron : Track {
		construct {
			/*position, velocity = 6*/
			dimensions = 6;
			name = "neutron";
			mass = 939.56556E6 * UNITS.EV;
			charge = 0.0;
			mdm = -1.913 * 1836.0 * UNITS.MU_BOHR;
			tolerance = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0};
			magnetic_helicity = 1;
		}

		public Neutron() { }
		private class _Vertex: Vertex {
			public _Vertex() {
			}
		}
		public override Vertex create_vertex() {
			return new _Vertex();
		}
		public override Vertex clone_vertex(Vertex source) {
			var rt = new _Vertex();
			rt.position = source.position;
			rt.velocity = source.velocity;
			rt.weight = source.weight;
			rt.timestamp= source.timestamp;
			rt.part = source.part;
			rt.volume = source.volume;
			return rt;
		}
	}
}
