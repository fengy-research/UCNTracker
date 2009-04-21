using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Neutron : PType {
		public Neutron() {
			this.name = "this";
			this.mass = 1.675*10e-24/*g*/;
			this.charge = 0.0;
			this.mdm = -9.6623640e-20/*1e-7 J/Tesla*/;
		}
		public override Vertex create_vertex() {
			return new Vertex();
		}
	}
}
