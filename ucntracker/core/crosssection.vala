using Vala.Runtime;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class CrossSection : Object, Buildable {
		public Type ptype {get; set;}
		public double mfp {get; set;}
		public virtual signal void hit(Track track, Vertex vertex);
	}
}
