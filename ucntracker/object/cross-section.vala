[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class CrossSection : Object, GLib.YAML.Buildable {
		public delegate double CrossSectionFunction(Track track, Vertex vertex);
		public double density {get; set;}
		public Type ptype {get; set;}
		public double const_sigma {get; set; default = 0.0;}
		public CrossSectionFunction sigmafunc = null;
		public virtual double sigma(Track track, Vertex vertex) {
			if(sigmafunc == null) return const_sigma;
			else return sigmafunc(track, vertex);
		}
		public virtual signal void hit(Track track, Vertex vertex);
	}
}
