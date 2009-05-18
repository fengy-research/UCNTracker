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
			
		}
		public virtual void process_property(Builder builder, string property_name, string property_value) throws Error {
			ParamSpec pspec = ((ObjectClass)this.get_type().class_peek).find_property(property_name);
			if(pspec == null) {
				string message = "Property %s.%s not found".printf(get_type().name(), property_name);
				throw new Error.PROPERTY_NOT_FOUND(message);
			}
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
			} else {
			if(pspec.value_type == typeof(Object)) {
				Object object = builder.get_object(property_value);
				if(object == null) {
					string message = "Object '%s' not found".printf(property_value);
					throw new Error.OBJECT_NOT_FOUND(message);
				}
				value.set_object(object);
			} else if(pspec.value_type.is_a(typeof(Boxed)));
				void* symbol = Demangler.resolve_function(pspec.value_type.name(), "parse");
				void* memory = malloc0(65500);
				ParseFunc func = (ParseFunc) symbol;
				func(property_value, memory);
				value.set_boxed(memory);
				free(memory);
			}
		}
	}
}
