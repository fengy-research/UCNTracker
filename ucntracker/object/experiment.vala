[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
public class Experiment: Object, GLib.YAML.Buildable {
	public List<Part> parts;
	public List<Field> fields;
	public List<Foil> foils;

	public static Endf.Loader endfs = new Endf.Loader();

	public double max_time_step {get; set; default=0.01;}

	public void add_child(GLib.YAML.Builder builder, GLib.Object child, string? type) throws Error {
		if(child is Part) {
			parts.insert_sorted(child as Part,
			      (CompareFunc) Part.layer_compare_func);
		}
		if(child is Field) {
			fields.prepend(child as Field);
		}
		if(child is Foil) {
			foils.prepend(child as Foil);
		}
		//(base as GLib.YAML.Buildable).add_child(builder, child, type);
	}


	public Type get_child_type(GLib.YAML.Builder builder, string tag) {
		if(tag == "parts") {
			return typeof(Part);
		}
		if(tag == "fields") {
			return typeof(Field);
		}
		if(tag == "foils") {
			return typeof(Foil);
		}
		return Type.INVALID;
	}
	internal void custom_node(GLib.YAML.Builder builder, string tag, GLib.YAML.Node node) throws GLib.Error {
		
		if(tag != "endf-list") {
			string message = "Property %s.%s not found".printf(get_type().name(), tag);
			throw new Error.PROPERTY_NOT_FOUND(message);
		}
		if(!(node is GLib.YAML.Node.Sequence)) {
				string message = "A sequence is expected for a endf-list tag (%s)"
				.printf(node.start_mark.to_string());
				throw new Error.CUSTOM_NODE_ERROR(message);
		}
		var sequence = node as GLib.YAML.Node.Sequence;
		foreach(var item in sequence.items) {
			var scalar = item as GLib.YAML.Node.Scalar;
			endfs.add_file(scalar.value);
			message("endf file %s loaded", scalar.value);
		}
	}
}}
