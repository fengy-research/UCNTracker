[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/**
	 * Border is the properties of the adjacent between two parts.
	 * */
	public class Border:Object, Buildable {
		public enum ChannelType {
		ANY = 0,
		DIFFUSE = 1,
		FERMI = 2,
		REFLECT = 3,
		ABSORB = 4,
		MAX_VALUE = 5
		}
		private MultiChannelRNG mcrng = new MultiChannelRNG(ChannelType.MAX_VALUE);
		public double diffuse {
			get {return mcrng.get_ch_width(ChannelType.DIFFUSE);} 
			set {mcrng.set_ch_width(ChannelType.DIFFUSE, value);}
		}
		public double fermi {
			get {return mcrng.get_ch_width(ChannelType.FERMI);} 
			set {mcrng.set_ch_width(ChannelType.FERMI, value);}
		}
		public double reflect {
			get {return mcrng.get_ch_width(ChannelType.REFLECT);} 
			set {mcrng.set_ch_width(ChannelType.REFLECT, value);}
		}
		public double absorb {
			get {return mcrng.get_ch_width(ChannelType.ABSORB);} 
			set {mcrng.set_ch_width(ChannelType.ABSORB, value);}
		}
		public double any {
			get {return mcrng.get_ch_width(ChannelType.ANY);} 
			set {mcrng.set_ch_width(ChannelType.ANY, value);}
		}

		public delegate bool BorderFunction (Track track,
				Vertex vertex_leave, Vertex vertex_enter);

		public BorderFunction border_function = null;

		public Track track;
		public Track forked_track;
		public Vertex enter;
		public Vertex leave;
		public bool transported;
		/**
		 * Emitted when a track goes through a surface.
		 *
		 */
		public signal void transport(Border.ChannelType chn);

		construct {
			mcrng.set_ch_function(ChannelType.FERMI, this.fermi_chn);
			mcrng.set_ch_function(ChannelType.REFLECT, this.reflect_chn);
			mcrng.set_ch_function(ChannelType.DIFFUSE, this.diffuse_chn);
			mcrng.set_ch_function(ChannelType.ABSORB, this.absorb_chn);
			mcrng.set_ch_function(ChannelType.ANY, this.any_chn);
		}
		internal void execute(Track track, Vertex leave, Vertex enter) {
			this.track = track;
			this.leave = leave;
			this.enter = enter;
			this.forked_track = null;
			this.transported = false;
			ChannelType chn = (ChannelType)mcrng.select(UniqueRNG.rng);
			transport(chn);
		}
		private void reflect_chn() {
			Vector norm = track.tail.volume.grad(leave.position);
			Vector reflected = leave.velocity.reflect(norm);
			leave.velocity = reflected;
			transported = false;
		}
		private void diffuse_chn() {
			Vector norm = track.tail.volume.grad(leave.position);
			Vector v = Vector(0,0,0);
			do {
		//		the new velocity has to be pointing inside
				Gsl.Randist.dir_3d(UniqueRNG.rng, out v.x,
							out v.y,
							out v.z);
			} while(v.dot(norm) >= -0.01) ;
			leave.velocity = v.mul(leave.velocity.norm());
			transported = false;
		}
		private void fermi_chn() {
			bool need_fork = UCNPhysics.TransportChannels.fermi(track, leave, enter);
			if(need_fork) {
				/* this misterious. if need_fork then the current track is bounced back,
				 * therefore transported == false*/
				forked_track = track.fork(track.get_type(), enter);
				transported = false;
			} else {
				transported = true;
			}
		}
		private void absorb_chn() {
			track.terminate();
			transported = false;
		}
		private void any_chn() {
			transported = border_function(track, leave, enter);
		}
	}
}
