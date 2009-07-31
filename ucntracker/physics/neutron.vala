using UCNTracker;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNPhysics {
	public class Neutron : Track {
		construct {
			/*position, velocity = 6*/
			/*spin = 3, spin_precession*/
			dimensions = 10;
			name = "neutron";
			mass = 939.56556 * UNITS.MEV_MASS;
			charge = 0.0;
			mdm = -1.913 / 1836.0 * UNITS.MU_BOHR;
			tolerance = {1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0};
			spin_parallel = 1;
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
			source.copy_to(rt);
			return rt;
		}
	}
}
