[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public interface Buildable : Object {
		public unowned GLib.YAML.Node.Mapping get_node() {
			return (GLib.YAML.Node.Mapping) get_data("yaml-node");
		}
		public virtual void set_node(GLib.YAML.Node.Mapping node) {
			this.set_data_full("yaml-node", g_yaml_node_ref(node), (DestroyNotify)g_yaml_node_unref);
		}
		public virtual unowned string get_name() {
			return (string) this.get_data("buildable-name");
		}
		public virtual void set_name(string name) {
			this.set_data_full("buildable-name", Memory.dup(name, (int) name.size() + 1), g_free);
		}
		[CCode (cname="g_yaml_node_ref")]
		internal extern static void* g_yaml_node_ref(void* node);
		[CCode (cname="g_yaml_node_unref")]
		internal extern static void g_yaml_node_unref(void* node);
	}
}
