using GLib;

namespace Vala.Runtime {
	public errordomain BuilderError {
		PROPERTY_NOT_FOUND,
		TYPE_NOT_FOUND,
		INVALID_VALUE,
	}
	public class Builder : GLib.Object {
		public string prefix {get; set;}
		private class Object : GLib.Object, Vala.Runtime.Buildable {

		}
		private class deferred_child_t {
			public Vala.Runtime.Buildable parent;
			public unowned YAML.Node node;
		}
		private YAML.Context context;

		private List<deferred_child_t> deferred_children;

		HashTable<unowned string, Buildable> object_hash = new HashTable<unowned string, Buildable>(direct_hash, direct_equal);
		construct {
			context = new YAML.Context(new YAML.Parser(node_start, node_end));
		}
		public uint add_from_string (string buffer, size_t length) {
			context.parse(buffer);
			return 0;
		}
		public extern bool value_from_string(ParamSpec pspec, string str, ref Value value) throws BuilderError;
		private bool node_start(YAML.Context pc, YAML.Node node) {
			return false;
		}
		private void visit_node(Buildable? parent, YAML.Node node) {
			if(node.type == YAML.NodeType.SEQ) {
				/*SEQ is always seq of objects*/
				foreach(weak YAML.Node seq_node in node.sequence) {
					visit_node(parent, seq_node);
				}
				return;
			}
			Buildable child = null;
			if(node.alias != null) {
				deferred_child_t dc = new deferred_child_t();
				dc.parent = parent;
				dc.node = node;
				deferred_children.append(#dc);
			} else
			if(node.type == YAML.NodeType.MAP) {
				weak string id = node.anchor;
				weak YAML.Node children_node = null;
				weak string class_name = null;
				/*Run one, for class and children_node*/
				foreach(weak YAML.Node map_node in node.mapping_list) {
					switch(map_node.key) {
						case "class":
							class_name = map_node.value;
						break;
						case "children":
							children_node = map_node;
						break;
					}
				}
				Type type = type_from_name(class_name);
				child = GLib.Object.new(type) as Buildable;
				object_hash.insert(node.anchor, child);
				if(children_node != null)
					visit_node(child, children_node);
				/*Run two, for properties*/
				foreach(weak YAML.Node map_node in node.mapping_list) {
					switch(map_node.key) {
						case "class":
						break;
						case "children":
						break;
						default:
						ObjectClass @class = (ObjectClass) type.class_ref();
						ParamSpec ps = @class.find_property(map_node.key);
						if(ps == null) {
							throw new BuilderError.PROPERTY_NOT_FOUND("property %s.%s not found".printf(type.name(), map_node.key));
						}
						Value value = {};
						value_from_string(ps, map_node.value, ref value);
						break;
					}
				}
			}
			if(parent != null && child != null) {
				parent.add_child(this, child);
			}
			if(node.key == "#doc") {
				foreach(deferred_child_t dc in deferred_children) {
					dc.parent.add_child(this, object_hash.lookup(dc.node.key));
				}
			}
		}
		private bool node_end(YAML.Context pc, YAML.Node node) {
			if(node.key != "#doc") return false;
			visit_node(null, node);
			return false;
		}
		public Buildable? get_object(string name) {
			return object_hash.lookup(name);
		}
		public static delegate Type TypeFunc();
		private static Type type_from_name(string name) {
			void* method = null;
			if(!resolve_method(name, "get_type", out method)) {
				throw new BuilderError.TYPE_NOT_FOUND("can't resolve %s", name);
				return Type.INVALID;
			}
			TypeFunc func = (TypeFunc)method;
			return func();
		}
		/* Try to resolve a method under a namespace/class
		 * */
		static Module module = null;
		public static bool resolve_method (string name,
		         string method, out void* func) {
			StringBuilder symbol_name = new StringBuilder("");
			unichar c = 0;
			unichar cc = 0;
			unichar ccc = 0;
			weak string p;
			int i = 0;
			if (module == null) module = Module.open(null, 0);
			for (p = name; 
				(c = p.get_char()) != 0; 
				ccc = cc, cc = c, p = p.next_char(), i++) {
				/* skip if uppercase, first or previous is uppercase */
				if ((c.isupper() && i > 0 && cc.islower())
				|| (i > 2 && c.isupper() && 
					cc.isupper() && ccc.isupper())) {
					symbol_name.append_unichar('_');
				}
				symbol_name.append_unichar(c.tolower());
			}
			symbol_name.append_unichar('_');
			symbol_name.append(method);
			
			message("_ %s  _", symbol_name.str);
			return module.symbol(symbol_name.str, out func);
		}
	}
}
