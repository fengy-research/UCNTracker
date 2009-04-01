using GLib;

namespace Vala.Runtime {
	public class Builder : GLib.Object {
		/*
		private YAML.Context context;
		HashTable<unowned string, Buildable> object_hash = new HashTable<unowned string, Buildable>(direct_hash, direct_equal);
		construct {
			context = new YAML.Context(new YAML.Parser(key_start, key_end));
		}
		public uint add_from_string (string buffer, size_t length) {
			return 0;
		}
		private bool key_start(YAML.Context pc, YAML.Key key) {
			return false;
		}
		private bool key_end(YAML.Context pc, YAML.Key key) {
			return false;
		}
		public Buildable? get_object(string name) {
			return object_hash.lookup(name);
		}*/
	}
}
