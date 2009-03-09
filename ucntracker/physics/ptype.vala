using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	[CompactType]
	public class PType {
		public string name;
		public double mass;
		public double charge;
		public static PType neutron;

		public static void preload() {
			/*dirty hack*/
			PType t = new PType();
		}
		class construct {
			message("class construct");
			neutron = new PType();
			neutron.name = "neutron";
			neutron.mass = 1.0;
			neutron.charge = 0.0;
		}
		static construct {
			message("static construct");
		}
	}
}
