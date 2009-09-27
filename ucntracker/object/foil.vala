[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Foil: Object, GLib.YAML.Buildable {
		public List<Surface> surfaces;
		private static const string[] tags = {"surfaces"};
		private static Type[] types= {typeof(Surface) };

		static construct {
			GLib.YAML.Buildable.register_type(typeof(Foil), tags, types);
		}

		public Border border {get; set; default = new Border();}
		public void add_child(GLib.YAML.Builder builder, GLib.Object child, string? type) throws Error {
			if(child is Surface ) {
				surfaces.prepend(child as Surface);
			} else {
				critical("expecting type %s for a child but found type %s",
					typeof(Surface).name(),
					child.get_type().name());
			}
		}
	}
}
