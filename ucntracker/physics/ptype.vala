using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/***
	 * UNITS:
	 * length == cm
	 * mass = gram
	 * time = second
	 * charge = columb
	 *
	 * energy = gram cm^2 second^-2 = 1e-7 J
	 * mdm = energy/Tesla = 1e-7 J/Tesla
	 */
	public abstract class PType {
		public string name;
		public double mass;
		public double charge;
		public double mdm;

		public abstract Vertex create_vertex();
		protected static HashTable<Type, PType> map;
		public static PType peek(Type type) {
			if(map == null) map = new HashTable<Type, PType>(direct_hash, direct_equal);
			PType ptype = map.lookup(type);
			if(ptype == null) {
				if(type == typeof(Neutron)) {
	//				ptype = new Neutron();
				} else error("Particle type doesn't exist");
				map.insert(type, ptype);
			}
			return ptype;
			
		}
	}
}
