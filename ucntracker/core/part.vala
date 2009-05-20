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
	public struct FermiPotential {
		public double f;
		public double V;
		[CCode (instance_pos = 2)]
		public bool parse(string foo) {
			string[] words = foo.split(" ");
			if(words == null || words.length != 2) 
				words = foo.split(",");
			if(words == null || words.length != 2) 
				return false;
			f = words[0].to_double();
			V = words[1].to_double();
			return true;
		}
		public FermiPotential(double f, double V) {
			this.f = f;
			this.V = V;
		}
	}

	public class Part: Object, Buildable {
		public List<Volume> volumes;
		public List<CrossSection> cross_sections;

		public HashTable<unowned Part, Transport> neighbours =
			new HashTable<unowned Part, Transport>(direct_hash, direct_equal);
		public int layer {get; set; default = 0;}
		private FermiPotential _potential = FermiPotential(0.0, 0.0);
		public FermiPotential potential {get {return _potential;} set{ _potential = value;}}

		public void add_child(Builder builder, GLib.Object child, string? type) throws Error {
			if(child is Volume) {
				volumes.prepend(child as Volume);
			} else if (child is CrossSection) {
				cross_sections.prepend(child as CrossSection);
			} else {
				critical("expecting type %s/%s for a child but found type %s",
					typeof(Volume).name(),
					typeof(CrossSection).name(),
					child.get_type().name());
			}
			/*VALA BUG!*/
			//base.add_child(builder, child, type);
		}

		internal void custom_node(Builder builder, string tag, void* node_pointer) throws Error {
			if(tag != "neighbours") {
				string message = "Property %s.%s not found".printf(get_type().name(), tag);
				throw new Error.PROPERTY_NOT_FOUND(message);
			}
			GLib.YAML.Node node = (GLib.YAML.Node)node_pointer;
			if(!(node is GLib.YAML.Node.Mapping)) {
				string message = "A mapping is expected for a neighbour tag (%s)"
				.printf(node.start_mark.to_string());
				throw new Error.CUSTOM_NODE_ERROR(message);
			}
			var mapping = node as GLib.YAML.Node.Mapping;
			foreach(var key in mapping.keys) {
				Part neib = cast_to_object(key.get_resolved()) as Part;
				GLib.YAML.Node value = mapping.pairs.lookup(key).get_resolved();
				value.tag = "!Transport";
				Transport trans = builder.build_object(value) as Transport;
				assert(neib != null);
				assert(trans!= null);
				neighbours.insert(neib, trans);
			}
		}
		/**
		 * emitted when a track tries to go through a surface.
		 * next == null if the track is getting into the ambient.
		 *
		 * transported: whether the track successfully transports 
		 *   to the next part.
		 *
		 * if true, 
		 *   the track continues to the next part.
		 *   v_enter should be set to the vertex for the transported track
		 *
		 * if false, 
		 *   the track doesn't continue to the next part.
		 *   v_leave should be set to the new vertex for the reflected track.
		 *
		 * in either case, the handler can fork the track at the surface
		 * to produce the track for the other case.
		 *
		 * NOTE: this syntax of ref bool depends on a local patch for
		 * Bug 574403
		 */
		public virtual signal void transport(Track track,
		       Vertex s_leave, Vertex s_enter, ref bool transported);

		public static int layer_compare_func(Part a, Part b) {
			return -(a.layer - b.layer);
		}

		public bool locate(Vector point, out unowned Volume child) {
			foreach(Volume volume in volumes) {
				Sense sense = volume.sense(point);
				if(sense == Sense.IN) {
					child = volume;
					return true;
				}
			}
			child = null;
			return false;
		}
		
	}
}
