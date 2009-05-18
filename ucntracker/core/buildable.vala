[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public interface Buildable : Object {
		private static delegate void ParseFunc(string foo, void* location);

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
		internal void process_children(Builder builder, GLib.YAML.Node node) throws Error {
			var children = node as GLib.YAML.Node.Sequence;
			foreach(var item in children.items) {
				var child = (Object) item.get_resolved().get_pointer();
				if (child == null) continue;
				add_child(builder, child, null);
			}
		}
		internal void process_property(Builder builder, ParamSpec pspec, GLib.YAML.Node node) throws Error {
			var value_scalar = (node as GLib.YAML.Node.Scalar);
			if(value_scalar == null) {
				string message = "Non-Scalar node as a property value for '%s' is not supported"
				.printf(pspec.name);
				throw new Error.NOT_IMPLEMENTED(message);
			}
			unowned string property_value = value_scalar.value;

			Value value = Value(pspec.value_type);
			if(pspec.value_type == typeof(int)) {
				value.set_int((int)property_value.to_long());
			} else
			if(pspec.value_type == typeof(uint)) {
				value.set_uint((uint)property_value.to_long());
			} else
			if(pspec.value_type == typeof(long)) {
				value.set_long(property_value.to_long());
			} else
			if(pspec.value_type == typeof(ulong)) {
				value.set_ulong(property_value.to_ulong());
			} else
			if(pspec.value_type == typeof(string)) {
				value.set_string(property_value);
			} else
			if(pspec.value_type == typeof(float)) {
				value.set_float((float)property_value.to_double());
			} else
			if(pspec.value_type == typeof(double)) {
				value.set_double(property_value.to_double());
			} else
			if(pspec.value_type == typeof(bool)) {
				value.set_boolean(property_value.to_bool());
			} else
			if(pspec.value_type == typeof(Type)) {
				value.set_gtype(Demangler.resolve_type(builder.get_full_class_name(property_value)));
			} else
			if(pspec.value_type == typeof(Object)) {
				Object ref_obj = builder.get_object(property_value);
				if(ref_obj == null) {
					string message = "Object '%s' not found".printf(property_value);
					throw new Error.OBJECT_NOT_FOUND(message);
				}
				value.set_object(ref_obj);
			} else
			if(pspec.value_type.is_a(typeof(Boxed))) {
				message("working on a boxed type %s <- %s", pspec.value_type.name(), property_value);
				void* symbol = Demangler.resolve_function(pspec.value_type.name(), "parse");
				void* memory = malloc0(65500);
				ParseFunc func = (ParseFunc) symbol;
				func(property_value, memory);
				value.set_boxed(memory);
				free(memory);
			} else {
				string message = "Unhandled property type %s".printf(pspec.value_type.name());
				throw new Error.UNKNOWN_PROPERTY_TYPE(message);
			}
			this.set_property(pspec.name, value);
			
		}
		/**
		 * To avoid explicit dependency on libyaml-glib, node is defined as void*
		 * It is actually a GLib.YAML.Node
		 */
		internal virtual void custom_node(Builder builder, string tag, void* node) throws Error {
			string message = "Property %s.%s not found".printf(get_type().name(), tag);
			throw new Error.PROPERTY_NOT_FOUND(message);
		}
	}
}
