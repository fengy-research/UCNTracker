using GLib;

namespace Vala.Runtime {
	public class Builder : GLib.Object {
		private YAML.Context context;
		HashTable<unowned string, Buildable> object_hash = new HashTable<unowned string, Buildable>(direct_hash, direct_equal);
		construct {
			context = new YAML.Context(new YAML.Parser(node_start, node_end));
		}
		public uint add_from_string (string buffer, size_t length) {
			return 0;
		}
		private bool node_start(YAML.Context pc, YAML.Node node) {
			return false;
		}
		private bool node_end(YAML.Context pc, YAML.Node node) {
			if(node.type == YAML.NodeType.MAP) {
				foreach(weak YAML.Node node in node.mapping_list) {
					switch(node.key) {
						case "object":
						break;
						case "class":
						break;
					}
				}
			}
			return false;
		}
		public Buildable? get_object(string name) {
			return object_hash.lookup(name);
		}
	}
}
