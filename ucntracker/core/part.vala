[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class FermiPotential:Object, Buildable {
		public double f {get; set;}
		public double V {get; set;}
	}

	public class Part: Object, Buildable {
		public List<Volume> volumes;
		public List<CrossSection> cross_sections;

		public HashTable<unowned Part, Border> neighbours =
			new HashTable<unowned Part, Border>(direct_hash, direct_equal);
		public int layer {get; set; default = 0;}
		public FermiPotential potential {get; set;}

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
				Part neib = builder.build_object(key.get_resolved(), typeof(Part)) as Part;
				GLib.YAML.Node value = mapping.pairs.lookup(key).get_resolved();
				Border trans = builder.build_object(value, typeof(Border)) as Border;
				assert(neib != null);
				assert(trans!= null);
				neighbours.insert(neib, trans);
			}
		}

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
		public Border? get_border(Part part) {
			return neighbours.lookup(part);
		}
	}
}
