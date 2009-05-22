[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
public class Experiment: Object, GLib.YAML.Buildable {
	public List<Part> parts;
	public List<Field> fields;

	public double max_time_step {get; set; default=0.01;}

	public void add_child(GLib.YAML.Builder builder, GLib.Object child, string? type) throws Error {
		if(child is Part) {
			parts.insert_sorted(child as Part,
			      (CompareFunc) Part.layer_compare_func);
		}
		if(child is Field) {
			fields.prepend(child as Field);
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
		return Type.INVALID;
	}
	public bool locate(Vector point,
	       out unowned Part located, out unowned Volume volume) {
		foreach(Part part in parts) {
			if(part.locate(point, out volume)) {
				located = part;
				return true;
			}
		}
		located = null;
		return false;
	}
	public Vector accelerate(Track track, Vertex Q) {
		Vector accel = Vector(0, 0, 0);
		Vector this_accel;
		Volume child;
		foreach(Field field in fields) {
			if(!field.locate(Q.position, out child)) continue;
			if(field.fieldfunc(track, Q.position, Q.velocity, out this_accel)){
				accel.x += this_accel.x;
				accel.y += this_accel.y;
				accel.z += this_accel.z;
			}
		}
		return accel;
	}
}}
