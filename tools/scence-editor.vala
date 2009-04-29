using GLib;
using Vala.Runtime;
using UCNTracker;

private errordomain Error {
	NO_EXPERIMENT,
}
public class ScenceEditor {
	Gtk.Window window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
	Gtk.TextView textview = new Gtk.TextView();
//	Gtk.Entry init_pos = new Gtk.Entry();
//	Gtk.Entry init_vel = new Gtk.Entry();
	UCNTracker.VertexEditor vertex_editor = new UCNTracker.VertexEditor();
	Gtk.FileChooserDialog dialog_open;
	UCNTracker.Experiment experiment = null;
	UCNTracker.Run run = null;
	string filename;
	Camera camera = new Camera();
	Gtk.UIManager ui = new Gtk.UIManager();
	private static const Gtk.ActionEntry[] ACTIONDEF = {
			{"toolbar", null, "Toolbar", null, null, action_callback},
			{"menubar", null, "Menubar", null, null, action_callback},
			{"file", null, "_File", null, null, action_callback},
			{"file-open", null, "_Open", null, null, action_callback},
			{"file-save", null, "_Save", null, null, action_callback},
			{"simulation", null, "_Simulation", null, null, action_callback},
			{"simulation-start", null, "_Start", null, null, action_callback},
			{"simulation-pause", null, "_Pause", null, null, action_callback},
			{"simulation-continue", null, "_Continue", null, null, action_callback},
			{"simulation-stop", null, "_Stop", null, null, action_callback},
			{"view", null, "_View", null, null, action_callback},
			{"view-refresh", null, "_Refresh", null, null, action_callback}
	};
	private static const string UIDEF = """
	<ui>
	<menubar action="menubar">
		<menu action="file">
			<menuitem action="file-open"/>
			<menuitem action="file-save"/>
		</menu>
		<menu action="simulation">
			<menuitem action="simulation-start"/>
			<menuitem action="simulation-pause"/>
			<menuitem action="simulation-continue"/>
			<menuitem action="simulation-stop"/>
		</menu>
		<menu action="view">
			<menuitem action="view-refresh"/>
		</menu>
	</menubar>
	<toolbar action="toolbar">
		<toolitem action="file-open"/>
		<toolitem action="file-save"/>
		<toolitem action="simulation-start"/>
		<toolitem action="simulation-stop"/>
		<toolitem action="view-refresh"/>
	</toolbar>
	</ui>""";

	public void init() {
		Pango.FontDescription font = Pango.FontDescription.from_string("monospace");
		Gtk.ScrolledWindow scroll = new Gtk.ScrolledWindow(null, null);

		dialog_open = new Gtk.FileChooserDialog("Open", window, 
					Gtk.FileChooserAction.OPEN, 
					Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL,
					Gtk.STOCK_OPEN, Gtk.ResponseType.ACCEPT, null);
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
		Gtk.MenuBar menubar = ui.get_widget("/menubar") as Gtk.MenuBar;

		pan.add1(camera);
		pan.add2(box_r);

		box.pack_start(menubar, false, true, 0);
		box.pack_start(toolbar, false, true, 0);
		box.pack_start(pan, true, true, 0);
//		box_r.pack_start(init_pos, false, true, 0);
//		box_r.pack_start(init_vel, false, true, 0);
		box_r.pack_start(vertex_editor, false, true, 0);
		scroll.add(textview);
		textview.set_scroll_adjustments(scroll.hadjustment, scroll.vadjustment);
		box_r.pack_start(scroll, true, true, 0);
		window.add(box);
		window.show_all();
	}
	private void action_callback(Gtk.Action action) {
		switch(action.name) {
			case "file-open":
				if(dialog_open.run() == Gtk.ResponseType.ACCEPT) {
					filename = dialog_open.get_filename();
				}
				dialog_open.hide();
				window.title = filename;
				open_file(filename);
			break;
			case "file-save":
				save_file(filename);
			break;
			case "view-refresh":
				string text = get_text_view_content();
				rebuild(text);
			break;
			case "simulation-start":
				if(run != null) {
					
				} else {
					run = experiment.add_run();
					run.attach();
				}
			break;
			case "simulation-stop":
				if(run != null) {
					run.stop();
				}
				run = null;
			break;
			case "simulation-continue":
				if(run != null) {
					run.continue();
				} else {
				}
			break;
			case "simulation-pause":
				if(run != null) {
					run.pause();
				}
			break;
		}
	}
	private string get_text_view_content() {
		Gtk.TextBuffer buffer = textview.get_buffer();
		Gtk.TextIter start;
		Gtk.TextIter end;
		buffer.get_start_iter(out start);
		buffer.get_end_iter(out end);
		return buffer.get_text(start, end, false);
	}
	private void set_text_view_content(string content) {
		Gtk.TextBuffer buffer = textview.get_buffer();
		buffer.set_text(content, -1);
	}
	private void rebuild(string yml) {
		Builder builder = new Builder();
		builder.add_from_string(yml, -1);
		List<unowned Object> list = builder.get_objects();
		experiment = null;
		foreach(Object obj in list) {
			if(obj is Experiment) {
				experiment = obj as Experiment;
				break;
			}
		}
		camera.experiment = experiment;
		if(experiment == null) {
			throw new Error.NO_EXPERIMENT("no experiment found in the yml file");
		}
		experiment.prepare += (obj, run) => {
			Track track = Track.new(typeof(Neutron));
			Vertex start = track.create_vertex();

			start.position = vertex_editor.position;
			start.velocity = vertex_editor.velocity;
			start.weight = 1.0;
			run.frame_length = 0.1;
			track.start(run, start);
			camera.run = null;
			camera.run = run;
		};
		experiment.finish += (obj, run) => {
			run = null;
		};
	}
	private void open_file(string filename) {
		string content;
		FileUtils.get_contents(filename, out content);
		set_text_view_content(content);
		rebuild(content);
	}
	private void save_file(string filename) {
		string content = get_text_view_content();
		FileUtils.set_contents(filename, content, -1);
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
