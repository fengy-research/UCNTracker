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
		THROUGH = 5,
		MAX_VALUE = 6,
		}

		private Gsl.RanDiscrete rd;
		private double[] channels = new double[(int)ChannelType.MAX_VALUE];

		public double diffuse {
			get {return channels[(int)ChannelType.DIFFUSE];} 
			set {
				channels[(int)ChannelType.DIFFUSE] = value; 
				rd = new Gsl.RanDiscrete(channels);
			}
		}
		public double fermi {
			get {return channels[(int)ChannelType.FERMI];} 
			set {
				channels[(int)ChannelType.FERMI] = value;
				rd = new Gsl.RanDiscrete(channels);
				
			}
		}
		public double reflect {
			get {return channels[(int)ChannelType.REFLECT];} 
			set {
				channels[(int)ChannelType.REFLECT] = value;
				rd = new Gsl.RanDiscrete(channels);
			}
		}
		public double absorb {
			get {return channels[(int)ChannelType.ABSORB];} 
			set {
				channels[(int)ChannelType.ABSORB] = value;
				rd = new Gsl.RanDiscrete(channels);
			}
		}
		public double any {
			get {return channels[(int)ChannelType.ANY];} 
			set {
				channels[(int)ChannelType.ANY] = value;
				rd = new Gsl.RanDiscrete(channels);
			}
		}

		public double through {
			get {
				return channels[(int)ChannelType.THROUGH];}
			set {
				channels[(int)ChannelType.THROUGH] = value;
				rd = new Gsl.RanDiscrete(channels);
			}
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
		 */
		public signal void transport(Border.ChannelType chn, ref Event event);

		internal void execute(ref Event event) {

			ChannelType chn = (ChannelType)rd.discrete(UniqueRNG.rng);
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
				case ChannelType.THROUGH:
				default:
					UCNPhysics.Transport.through(ref event);
				break;
			}
			transport(chn, ref event);
		}
	}
}
