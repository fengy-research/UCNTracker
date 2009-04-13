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
		private YAML.Context context;

		private List<deferred_child_t> deferred_children;

		HashTable<string, Buildable> object_hash = new HashTable<string, Buildable>(str_hash, str_equal);
		construct {
			context = new YAML.Context(new YAML.Parser(node_start, node_end));
		}
		public uint add_from_string (string buffer, size_t length) {
			context.parse(buffer);
			return 0;
		}
		public uint add_from_file (string filename) {
			string buffer;
			ulong length;
			FileUtils.get_contents(filename, out buffer, out length);
			return add_from_string(buffer, length);
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
				if(node.anchor != null) {
					child.set_name(node.anchor);
					object_hash.insert(node.anchor, child);
				}
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
						child.set_property(ps.name, value);
						break;
					}
				}
			}
			if(parent != null && child != null) {
				parent.add_child(this, child, null);
			}
		}
		private bool node_end(YAML.Context pc, YAML.Node node) {
			if(node.key != "#doc") return false;
			visit_node(null, node);
			foreach(deferred_child_t dc in deferred_children) {
				Buildable c = object_hash.lookup(dc.node.alias);
				dc.parent.add_child(this, c, null);
			}
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
		public extern static bool resolve_method (string name,
		         string method, out void* func);
		private class deferred_child_t {
			public Vala.Runtime.Buildable parent;
			public unowned YAML.Node node;
		}

	}
}
