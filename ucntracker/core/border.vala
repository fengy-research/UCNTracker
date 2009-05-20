[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/**
	 * Border is the properties of the adjacent between two parts.
	 * */
	public class Border:Object, Buildable {
		public enum Type {
		ANY = 0,
		DIFFUSE = 1,
		FERMI = 2,
		REFLECT = 3,
		ABSORB = 4,
		MAX_VALUE = 5
		}
		private MultiChannelRNG mcrng = new MultiChannelRNG(Type.MAX_VALUE);
		public double diffuse {
			get {return mcrng.get_ch_width(Type.DIFFUSE);} 
			set {mcrng.set_ch_width(Type.DIFFUSE, value);}
		}
		public double fermi {
			get {return mcrng.get_ch_width(Type.FERMI);} 
			set {mcrng.set_ch_width(Type.FERMI, value);}
		}
		public double reflect {
			get {return mcrng.get_ch_width(Type.REFLECT);} 
			set {mcrng.set_ch_width(Type.REFLECT, value);}
		}
		public double absorb {
			get {return mcrng.get_ch_width(Type.ABSORB);} 
			set {mcrng.set_ch_width(Type.ABSORB, value);}
		}
		public double any {
			get {return mcrng.get_ch_width(Type.ANY);} 
			set {mcrng.set_ch_width(Type.ANY, value);}
		}

		public delegate bool BorderFunction (Track track,
				Vertex vertex_leave, Vertex vertex_enter);

		public BorderFunction border_function = null;

		private Track track;
		private Vertex enter;
		private Vertex leave;

		construct {
			mcrng.set_ch_function(Type.FERMI, this.fermi_chn);
			mcrng.set_ch_function(Type.REFLECT, this.reflect_chn);
			mcrng.set_ch_function(Type.DIFFUSE, this.diffuse_chn);
			mcrng.set_ch_function(Type.ABSORB, this.absorb_chn);
			mcrng.set_ch_function(Type.ANY, this.any_chn);
		}
		public bool execute(Track track, Vertex leave, Vertex enter) {
			this.track = track;
			this.leave = leave;
			this.enter = enter;
			message("%lf %lf %lf", absorb, reflect, fermi);
			return mcrng.select(UniqueRNG.rng);
		}
		private bool reflect_chn() {
			Vector norm = track.tail.volume.grad(leave.position);
			Vector reflected = leave.velocity.reflect(norm);
			leave.velocity = reflected;
			return false;
		}
		private bool diffuse_chn() {
			Vector norm = track.tail.volume.grad(leave.position);
			Vector v = Vector(0,0,0);
			do {
		//		the new velocity has to be pointing inside
				Gsl.Randist.dir_3d(UniqueRNG.rng, out v.x,
							out v.y,
							out v.z);
			} while(v.dot(norm) >= -0.01) ;
			leave.velocity = v.mul(leave.velocity.norm());
			return false;
		}
		private bool fermi_chn() {
			return UCNPhysics.TransportChannels.fermi(track, leave, enter);
		}
		private bool absorb_chn() {
			track.terminate();
			return false;
		}
		private bool any_chn() {
			/* FIXME: call a private delegate */
			return border_function(track, leave, enter);
		}
	}
}
