using GLib;
using Vala.Runtime;
using UCNTracker;

public class ScenceEditor {
	Gtk.Window window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
	Gtk.TextView textview = new Gtk.TextView();
	Gtk.Entry init_pos = new Gtk.Entry();
	Gtk.Entry init_vel = new Gtk.Entry();

	Camera camera = new Camera();
	Gtk.UIManager ui = new Gtk.UIManager();
	private static const Gtk.ActionEntry[] ACTIONDEF = {
			{"toolbar", null, "Toolbar", null, null, action_callback},
			{"file-open", null, "Open", null, null, action_callback},
			{"run-start", null, "Run", null, null, action_callback},
			{"camera-refresh", null, "Refresh", null, null, action_callback}
	};
	private static const string UIDEF = """
	<ui>
	<toolbar action="toolbar">
		<toolitem action="file-open"/>
		<toolitem action="run-start"/>
		<toolitem action="camera-refresh"/>
	</toolbar>
	</ui>""";

	public void init() {
		Pango.FontDescription font = Pango.FontDescription.from_string("monospace");
		Gtk.ScrolledWindow scroll = new Gtk.ScrolledWindow(null, null);

		camera.set_size_request(200, 200);
		textview.set_size_request(200, 200);
		textview.modify_font(font);
		Gtk.Paned pan = new Gtk.HPaned();
		Gtk.Box box = new Gtk.VBox(false, 0);
		Gtk.Box box_r= new Gtk.VBox(false, 0);

		Gtk.ActionGroup ag = new Gtk.ActionGroup("Actions");
		ag.add_actions(ACTIONDEF, this);
		ui.insert_action_group(ag, 0);
		ui.add_ui_from_string(UIDEF, -1);
		Gtk.Toolbar toolbar = ui.get_widget("/toolbar") as Gtk.Toolbar;

		pan.add1(camera);
		pan.add2(box_r);

		box.pack_start(toolbar, false, true, 0);
		box.pack_start(pan, true, true, 0);
		box_r.pack_start(init_pos, false, true, 0);
		box_r.pack_start(init_vel, false, true, 0);
		scroll.add(textview);
		textview.set_scroll_adjustments(scroll.hadjustment, scroll.vadjustment);
		box_r.pack_start(scroll, true, true, 0);
		window.add(box);
		window.show_all();
	}
	private void action_callback(Gtk.Action action) {
		switch(action.name) {
			case "camera-refresh":
				Builder builder = new Builder();
				Gtk.TextBuffer buffer = textview.get_buffer();
				Gtk.TextIter start;
				Gtk.TextIter end;
				buffer.get_start_iter(out start);
				buffer.get_end_iter(out end);
				string text = buffer.get_text(start, end, false);
				builder.add_from_string(text, -1);
				camera.experiment = builder.get_object("experiment") as Experiment;
			break;
			case "run-start":
				camera.experiment.prepare += (obj, run) => {
					Track track = Track.new(typeof(Neutron));
					Vertex start = track.create_vertex();
					start.position.parse(init_pos.text);
					start.velocity.parse(init_vel.text);
					start.weight = 1.0;
					run.frame_length = 0.1;
					track.start(run, start);
				};
				Run run = camera.experiment.add_run();
				camera.run = run;
				camera.experiment.attach_run(run);
			break;
		}
	}
	public static int main(string[] args) {
		UCNTracker.init(ref args);
		Gtk.init(ref args);
		Gtk.gl_init(ref args);

		ScenceEditor app = new ScenceEditor();
		
		app.init();

		Gtk.main();
		return 0;
	}

}
