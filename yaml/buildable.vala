namespace Vala.Runtime {
	public interface Buildable : Object {
		public abstract void add_child(Builder builder, Object child);
		public virtual string name {
			get {
				return (string) this.get_data("buildable-name");
			}
			set {
				this.set_data_full("buildable-name", Memory.dup(value, (int) value.size() + 1), g_free);
			}
		}
	}
}
