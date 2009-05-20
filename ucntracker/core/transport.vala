[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Transport :Object, Buildable {
		private const int _DIFFUSE = 0;
		private const int _FERMI = 1;
		private const int _REFLECT = 2;
		private const int _ANY = 3;
		private MultiChannelRNG mcrng = new MultiChannelRNG(4);
		public double diffuse {
			get {return mcrng.get_ch_width(_DIFFUSE);} 
			set {mcrng.set_ch_width(_DIFFUSE, value);}
		}
		public double fermi {
			get {return mcrng.get_ch_width(_FERMI);} 
			set {mcrng.set_ch_width(_FERMI, value);}
		}
		public double reflect {
			get {return mcrng.get_ch_width(_REFLECT);} 
			set {mcrng.set_ch_width(_REFLECT, value);}
		}
		public double any {
			get {return mcrng.get_ch_width(_ANY);} 
			set {mcrng.set_ch_width(_ANY, value);}
		}

		private Track track;
		private Vertex enter;
		private Vertex leave;

		public Transport() { }
		construct {
			mcrng.set_ch_function(0, this.fermi_chn);
			mcrng.set_ch_function(1, this.reflect_chn);
			mcrng.set_ch_function(2, this.diffuse_chn);
			mcrng.set_ch_function(3, this.any_chn);
		}
		public bool execute(Track track, Vertex leave, Vertex enter) {
			this.track = track;
			this.leave = leave;
			this.enter = enter;
			message("%lf %lf %lf", diffuse, reflect, fermi);
			return mcrng.select(UniqueRNG.rng);
		}
		private bool reflect_chn() {
			UCNPhysics.TransportChannels.reflect(track, leave);
			return false;
		}
		private bool diffuse_chn() {
			UCNPhysics.TransportChannels.diffuse(track, leave);
			return false;
		}
		private bool fermi_chn() {
			return UCNPhysics.TransportChannels.fermi(track, leave, enter);
		}
		private bool any_chn() {
			/* FIXME: call a private delegate */
			return false;
		}
	}
}
