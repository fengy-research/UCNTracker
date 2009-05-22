[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Builder : GLib.Object {
		private string prefix = null;
		private HashTable<string, Object> anchors = new HashTable<string, Object>(str_hash, str_equal);
		private List<Object> objects;

		private GLib.YAML.Document document;
		public Builder(string? prefix = null) {
			this.prefix = prefix;
		}
		public void add_from_string(string str) throws GLib.Error {
			assert(document == null);
			document = new GLib.YAML.Document.from_string(str);
			bootstrap_objects(document);
			process_value_nodes();
		}
		public void add_from_file (FileStream file) throws GLib.Error {
			assert(document == null);
			document = new GLib.YAML.Document.from_file(file);
			bootstrap_objects(document);
			process_value_nodes();
		}

		internal Object build_object(GLib.YAML.Node node) throws GLib.Error {
			Object obj = bootstrap_object(node);
			process_object_value_nodes(obj, node);
			return obj;
		}

		internal string get_full_class_name(string class_name) {
			if(prefix != null)
				return prefix + "." + class_name;
			else
				return class_name;
		}

		private void bootstrap_objects(GLib.YAML.Document document) 
		throws GLib.Error {
			foreach(var node in document.nodes) {
				/* skip non objects */
				if(!(node is GLib.YAML.Node.Mapping)) continue;
				if(node.tag.get_char() != '!') continue;
				bootstrap_object(node);
			}
		}

		private void process_value_nodes() throws GLib.Error {
			foreach(var obj in objects) {
				var node = (GLib.YAML.Node)obj.get_data("node");
				process_object_value_nodes(obj, node);
			}
			
		}

		private Object bootstrap_object(GLib.YAML.Node node) throws GLib.Error {
			string real_name = get_full_class_name(node.tag.next_char());
			try {
				Type type = Demangler.resolve_type(real_name);
				message("%s", type.name());
				Object obj = Object.new(type);
				if(!(obj is Buildable)) {
					string message = 
					"Object type %s(%s) is not a buildable"
					.printf(type.name(), node.start_mark.to_string());
					throw new Error.NOT_A_BUILDABLE(message);
				}
				Buildable buildable = obj as Buildable;
				buildable.set_name(node.anchor);
				if(node.anchor != null) {
					anchors.insert(node.anchor, obj);
				}
				node.set_pointer(obj.ref(), g_object_unref);
				obj.set_data("node", node);
				objects.prepend(obj);
				return obj;
			} catch (Error.SYMBOL_NOT_FOUND e) {
				string message =
				"Type %s(%s) is not found".
				printf(real_name, node.start_mark.to_string());
				throw new Error.TYPE_NOT_FOUND(message);
			}
		}

		private void process_object_value_nodes(Object obj, GLib.YAML.Node node) throws GLib.Error {
			Buildable buildable = obj as Buildable;
			var mapping = node as GLib.YAML.Node.Mapping;
			foreach(var key in mapping.keys) {
				assert(key is GLib.YAML.Node.Scalar);
				var scalar = key as GLib.YAML.Node.Scalar;
				var value = mapping.pairs.lookup(key).get_resolved();
				if(scalar.value == "objects") {
					(obj as Buildable).process_children(this, value);
					continue;
				}
				ParamSpec pspec = ((ObjectClass)obj.get_type().class_peek()).find_property(scalar.value);
				if(pspec != null) {
					(obj as Buildable).process_property(this, pspec, value);
				} else {
					(obj as Buildable).custom_node(this, scalar.value, value);
				}
			}
			
		}
		/** 
		 * if anchor == null, return the object built by the root node of the yaml file
		 * Do not throw exceptions.
		 */
		public Object? get_object(string? anchor) {
			if(anchor != null)
			return anchors.lookup(anchor);
			else 
			return document.root.get_pointer() as Object;
		}
		public unowned List<Object>? get_objects() {
			return objects;
		}
	}
	/**
	 * Demangle vala names to c names in the standard way.
	 **/
	internal static class Demangler {
		/**
		 * A yet powerful Vala type name to c name demangler.
		 *
		 * vala_class_name: the class name. eg, UCN.ColdNeutron
		 *
		 * [ warning:
		 *   Notice that GI information is not used, therefore
		 *   the CCode annotation is not awared.
		 * ]
		 * */
		public static string demangle(string vala_name) {
			StringBuilder sb = new StringBuilder("");

			bool already_underscoped = false;
			unowned string p0 = null;
			unowned string p1 = vala_name;
			unichar c0 = 0;
			unichar c1 = p1.get_char();
			for(;
			    c1 != 0;
			    p0 = p1, c0 = c1, p1 = p1.next_char(), c1 = p1.get_char()) {

				/* Do not take any real action before we have two chars. */
				if(c0 == 0) continue;

				if(c0.islower() && c1.isupper()) {
					sb.append_unichar(c0.tolower());
					sb.append_unichar('_');
					already_underscoped = true;
					continue;
				}
				if(c0.isupper() && c1.islower()) {
					if(!already_underscoped) {
						sb.append_unichar('_');
					}
					sb.append_unichar(c0.tolower());
					already_underscoped = false;
					continue;
				}
				
				if(c0 == '.') {
					sb.append_unichar('_');
					already_underscoped = true;
					continue;
				} else {
					sb.append_unichar(c0.tolower());
					already_underscoped = false;
					continue;
				}
			}
			sb.append_unichar(c0.tolower());
			return sb.str;
		}
		public static void * resolve_function(string class_name, 
				string member_name) throws Error {
			void * symbol;
			StringBuilder sb = new StringBuilder("");
			sb.append(Demangler.demangle(class_name));
			sb.append_unichar('_');
			sb.append(Demangler.demangle(member_name));
			string func_name = sb.str;
			Module self = Module.open(null, 0);
			if(!self.symbol(func_name, out symbol)) {
				string message =
				"Symbol %s.%s (%s) not found"
				.printf(class_name, member_name, func_name);
				throw new Error.SYMBOL_NOT_FOUND(message);
			}
			return symbol;
		}
		private static delegate Type TypeFunc();
		public static Type resolve_type(string class_name) throws Error {
			void* symbol = resolve_function(class_name, "get_type");
			TypeFunc type_func = (TypeFunc) symbol;
			return type_func();
		}
	}
}
