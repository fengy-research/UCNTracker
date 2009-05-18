[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public interface Buildable : Object {

		public virtual unowned string get_name() {
			return (string) this.get_data("buildable-name");
		}
		public virtual void set_name(string? name) {
			if(name != null) {
				this.set_data_full("buildable-name", Memory.dup(name, (int) name.size() + 1), g_free);
			} else {
				this.set_data("buildable-name", null);
			}
		}
		public virtual void add_child(Builder builder, Object child, string? type) throws Error {
			message("Adding %s to %s", (child as Buildable).get_name(), this.get_name());
		}
	}
}
