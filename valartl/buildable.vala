namespace Vala.Runtime {
	public interface Buildable : Object {
		public virtual void add_child(Builder builder, Object child, string? type) {}
		public virtual unowned string get_name() {
			return (string) this.get_data("buildable-name");
		}
		public virtual void set_name(string name) {
			this.set_data_full("buildable-name", Memory.dup(name, (int) name.size() + 1), g_free);
		}
	}
}
