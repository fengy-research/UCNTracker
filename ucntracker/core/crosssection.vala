using Vala.Runtime;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class CrossSection : Object, Buildable {
		public static delegate double CrossSectionFunction(Track track, Vertex vertex);
		public double density {get; set;}
		public Type ptype {get; set;}
		public CrossSectionFunction sigma {get; set; default = default_sigma;}
		public virtual signal void hit(Track track, Vertex vertex);
		private static double default_sigma(Track track, Vertex vertex) {
			return double.INFINITY;
		}
	}
}
