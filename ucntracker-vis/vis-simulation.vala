
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class VisSimulation: Simulation {

		public Camera camera = new UCNTracker.Camera ();
		public Gtk.Window window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
		public Gtk.Box widget_box = new Gtk.VBox(false, 0);
		public VisSimulation(string experiment_objname) {
			base(experiment_objname);
		}
		public override void init() throws GLib.Error {
			base.init();
			camera.experiment = experiment;
			camera.set_size_request(200, 200);
			window.add(widget_box);
		}
		public override void run(bool attach = true) {
			window.show_all();
			base.run(attach);
		}
	}
}
