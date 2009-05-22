
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class VisSimulation: Simulation {

		public Camera camera = new UCNTracker.Camera ();
		public Gtk.Window window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
		public Gtk.Box widget_box = new Gtk.VBox(false, 0);
		private bool widgets_filled = false;
		public VisSimulation() {
			base();
		}
		public VisSimulation.with_anchor(string experiment_objname ) {
			base.with_anchor(experiment_objname);
		}
		static construct {
			if(!vis_initialized) {
				UCNTracker.vis_init();
			}
		}
		public override void init() throws GLib.Error {
			base.init();
			camera.experiment = experiment;
			if(!first_time_init) return;
			camera.set_size_request(200, 200);
			window.add(widget_box);
			widget_box.pack_start(camera, true, true, 0);
			window.destroy += this.quit;
			prepare += (obj, run) => {
				camera.run = run;
			};
		}
		public override void run(bool auto_attach = true, bool auto_quit = true) {
			window.show_all();
			base.run(auto_attach, auto_quit);
		}
	}
}
