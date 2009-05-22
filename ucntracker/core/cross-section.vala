[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class CrossSection : Object, Buildable {
		public static delegate double CrossSectionFunction(Track track, Vertex vertex);
		public double density {get; set;}
		public Type ptype {get; set;}
		private bool is_const = true;
		private double _const_sigma = 0.0;
		public double const_sigma {
			get { return _const_sigma; }
			set { _const_sigma = value; }
		}
		private CrossSectionFunction _sigmafunc = null;
		public CrossSectionFunction sigmafunc {
			get { return _sigmafunc;} 
			set { _sigmafunc = value; is_const = (_sigmafunc == null);}
		}
		public double sigma(Track track, Vertex vertex) {
			if(is_const) return const_sigma;
			else return sigmafunc(track, vertex);
		}
		public virtual signal void hit(Track track, Vertex vertex);
	}
}
