[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Builder : GLib.Object {
		private string prefix = null;
		private HashTable<string, Object> objects;

		public Builder(string? prefix = null) {
			this.prefix = prefix;
		}
		public void add_from_string(string str) throws Error {
			var document = new GLib.YAML.Document.from_string(str);
			foreach(var node in document.nodes) {
				if(node is GLib.YAML.Node.Alias) continue;
				if(node is GLib.YAML.Node.Mapping) {
					message("%s", node.tag);
				}
			}
		}

		public Object? get_object(string anchor) {
			return objects.lookup(anchor);
		}
	}
}
