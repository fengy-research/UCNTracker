[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/**
	 * Border is the properties of the adjacent between two parts.
	 * */
	public class Border:Object, GLib.YAML.Buildable {
		public struct Event {
			public Track track;
			public Vector normal;
			public Vertex leave;
			public Vertex enter;
			public Track forked_track;
			public bool transported;
		}
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

		public delegate bool BorderFunction (ref Event event);

		public BorderFunction border_function = null;

		public Track track;
		public Track forked_track;
		public Vertex enter;
		public Vertex leave;
		public Vector normal;
		public bool transported;
		/**
		 * Emitted when a track goes through a surface.
		 *
		 */
		public signal void transport(Border.ChannelType chn, ref Event event);

		construct {
		}
		internal void execute(ref Event event) {

			ChannelType chn = (ChannelType)mcrng.select(UniqueRNG.rng);
			switch(chn) {
				case ChannelType.FERMI:
					UCNPhysics.Transport.fermi(ref event);
				break;
				case ChannelType.REFLECT: 
					UCNPhysics.Transport.reflect(ref event);
				break;
				case ChannelType.DIFFUSE: 
					UCNPhysics.Transport.diffuse(ref event);
				break;
				case ChannelType.ABSORB: 
					UCNPhysics.Transport.absorb(ref event);
				break;
				case ChannelType.ANY: 
					if(border_function == null) {
						critical("border_function not set for the ANY channel");
					} else
						border_function(ref event);
				break;
			}
			transport(chn, ref event);
		}
	}
}
