using GLib;
using Gtk;
using GL;
using GLU;
using Math;

using UCNTracker;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Camera: Gtk.DrawingArea {
		public enum RenderMode {
			WIRE,
			WIRE_SOLID,
			SOLID
		}
		private Run _run;
		private Experiment _experiment;
		private uint scence_id;
		private Renderer renderer = new Renderer();
		private Tracer tracer = new Tracer();
		private Gtk.Menu popup = null;
		private Gtk.UIManager ui = new Gtk.UIManager();
		private RenderMode _mode = RenderMode.WIRE_SOLID;

		private void rerender() {
			if(scence_id != 0) {
				renderer.delete(scence_id);
				scence_id = 0;
			}
			if(this.is_realized() && _experiment != null) {
				scence_id = renderer.render(_experiment);
				message("scence_id = %u", scence_id);
			}
		}
		public Experiment experiment {
			get {
				return _experiment;
			}
			set {
				_experiment = value;
				rerender();
				this.queue_draw();
			}
		}

		public RenderMode mode {
			get {
				return _mode;
			}
			set {
				_mode = value;
				switch(_mode) {
					case RenderMode.WIRE:
					glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
					break;
					case RenderMode.WIRE_SOLID:
					glPolygonMode(GL_FRONT, GL_LINE);
					glPolygonMode(GL_BACK, GL_FILL);
					break;
					case RenderMode.SOLID:
					glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
					break;
				}
				queue_draw();
			}
		}
		public Run run {
			get {
				return _run;
			}
			set {
				if(_run != null) {
					_run.run_motion_notify -= run_motion_notify;
					_run.track_added_notify -= track_added_notify;
				}
				_run = value;
				if(_run != null) {
					_run.run_motion_notify += run_motion_notify;
					_run.track_added_notify += track_added_notify;
				}
			}
		}

		private void run_motion_notify(Run obj) {
			foreach (Track track in run.tracks) {
				push_track_history(track, track.tail);
			}
			queue_draw();
		}
		private double r = 0.0;
		private double g = 0.0;
		private double b = 0.0;
		private void track_added_notify(Run obj, Track track) {
			set_track_color(track, r, g, b);
			r = r + 0.1;
			g = g + 0.1;
			b = b + 0.1;
			if(r > 1.0) r /= 2.0;
			if(g > 1.0) g /= 2.0;
			if(b > 1.0) b /= 2.0;
		}
		//workaround bg 576122:
		private Vector _location = Vector(80, 0, 0);
		private Vector _target = Vector(0, 0, 0);
		private Vector _up = Vector(0, 0, 1);

		public Vector location {
			get {return _location;} 
			set {_location = value;
				queue_draw();
			}
		}
		public Vector target {
			get {return _target;} 
			set {_target = value;
				queue_draw();
			}
		}
		public Vector up {
			get {return _up;} 
			set {_up = value;
				queue_draw();
			}
		}

		private static const Gtk.ActionEntry[] ACTIONDEF = {
			{"popup", null, "Popup", null, null, action_callback_actions},
			{"location", null, "Location", null, null, action_callback_actions},
			{"location-top", null, "Top", null, null, action_callback_actions},
			{"location-bottom", null, "bottom", null, null, action_callback_actions},
			{"location-left", null, "Left", null, null, action_callback_actions},
			{"location-right", null, "Right", null, null, action_callback_actions},
			{"location-front", null, "Front", null, null, action_callback_actions},
			{"location-back", null, "Back", null, null, action_callback_actions},
			{"zoom", null, "Zoom", null, null, action_callback_actions},
			{"zoom-in", null, "Zoom In", null, null, action_callback_actions},
			{"zoom-out", null, "Zoom Out", null, null, action_callback_actions},
			{"mode", null, "Mode", null, null, action_callback_actions},
			{"mode-wire-solid", null, "WireSolid", null, null, action_callback_actions},
			{"mode-wire", null, "Wire", null, null, action_callback_actions},
			{"mode-solid", null, "Solid", null, null, action_callback_actions}
		};

		private static const string UIDEF = """
<ui>
<popup name="Popup" action="popup">
	<menu action="location">
		<menuitem action="location-top"/>
		<menuitem action="location-bottom"/>
		<menuitem action="location-left"/>
		<menuitem action="location-right"/>
		<menuitem action="location-front"/>
		<menuitem action="location-back"/>
	</menu>
	<menu action="zoom">
		<menuitem action="zoom-in"/>
		<menuitem action="zoom-out"/>
	</menu>
	<menu action="mode">
		<menuitem action="mode-wire-solid"/>
		<menuitem action="mode-wire"/>
		<menuitem action="mode-solid"/>
	</menu>
</popup>
</ui>""";

		construct {
			this.add_events(
				Gdk.EventMask.BUTTON_MOTION_MASK |
				Gdk.EventMask.POINTER_MOTION_HINT_MASK |
				Gdk.EventMask.BUTTON_PRESS_MASK |
				Gdk.EventMask.BUTTON_RELEASE_MASK |
				Gdk.EventMask.SCROLL_MASK
			);
			this.set_double_buffered(false);
			Gdk.GLConfigMode mode = 
		                  	  Gdk.GLConfigMode.RGB |
		                  	  Gdk.GLConfigMode.DEPTH;
			if(Environment.get_variable("UCN_VIS_SINGLE_BUFFER") != null) {
				message("fallback to single bufferred OpenGL");
				mode |= Gdk.GLConfigMode.SINGLE;
			} else
				mode |= Gdk.GLConfigMode.DOUBLE;
			Gdk.GLConfig config = new Gdk.GLConfig.by_mode (mode);


			Gtk.WidgetGL.set_gl_capability (this,
		             	 config, null, true,
		             	 Gdk.GLRenderType.RGBA_TYPE);
			Gtk.ActionGroup ag = new Gtk.ActionGroup("ViewActions");
			ag.add_actions(ACTIONDEF, this);
			ui.insert_action_group(ag, 0);
			try {
			ui.add_ui_from_string(UIDEF , -1);
			} catch (GLib.Error e) {
				error("Creating UI failed. %s", e.message);
			}
			this.popup = ui.get_widget("/Popup") as Gtk.Menu;
		}

		private int drag_start_x = 0;
		private int drag_start_y = 0;
		private int drag_end_x = 0;
		private int drag_end_y = 0;

		public override bool button_press_event(Gdk.EventButton event) {
			switch(event.button) {
				case 1:
					get_pointer(out drag_start_x, out drag_start_y);
				break;
				case 2:
					get_pointer(out drag_start_x, out drag_start_y);
				break;
				case 3:
					popup.popup(null, null, null,
					     event.button,
					     Gtk.get_current_event_time());
				break;
			}
			return true;
		}

		public override bool button_release_event(Gdk.EventButton event) {
			get_pointer(out drag_end_x, out drag_end_y);
			double dy = (drag_end_y - drag_start_y) / (double) allocation.height;
			double dx = (drag_end_x - drag_start_x) / (double) allocation.width;
			Vector x_vector = _location.direction().cross(_up).direction();
			Vector y_vector = _up;
			switch(event.button) {
				case 1:
					Quaternion q = Quaternion.from_rotation(
							y_vector, -dx * 1.57);
					Quaternion p = Quaternion.from_rotation(
							x_vector, dy * 1.57);
					message("%lf %s",  dy, _location.direction().to_string());
					_location = q.rotate_vector(_location);
					_location = p.rotate_vector(_location);
					message("location rotated to %s", _location.to_string());
				break;
				case 2:
					double d = _location.norm();
					_target.translate(x_vector.mul(dx * d).add(y_vector.mul(dy * d)));
					message("center moved rotated to %s", _target.to_string());
				break;
				case 3:
				break;
			}
			queue_draw();
			return true;
		}

		public override bool scroll_event(Gdk.EventScroll event) {
			switch(event.direction) {
				case Gdk.ScrollDirection.UP:
					do_action("zoom-in");
				break;
				case Gdk.ScrollDirection.DOWN:
					do_action("zoom-out");
				break;
			}
			return true;
		}

		private void do_action(string name) {
			double d = location.norm();
			switch(name) {
				case "location-top":
					location = Vector(0, 0, d);
					target = Vector(0, 0, 0);
					up = Vector(0, 1, 0);
				break;
				case "location-bottom":
					location = Vector(0, 0, -d);
					target = Vector(0, 0, 0);
					up = Vector(0, 1, 0);
				break;
				case "location-front":
					location = Vector(d, 0, 0);
					target = Vector(0, 0, 0);
					up = Vector(0, 0, 1);
				break;
				case "location-back":
					location = Vector(-d, 0, 0);
					target = Vector(0, 0, 0);
					up = Vector(0, 0, 1);
				break;
				case "location-left":
					location = Vector(0, -d, 0);
					target = Vector(0, 0, 0);
					up = Vector(0, 0, 1);
				break;
				case "location-right":
					location = Vector(0, d, 0);
					target = Vector(0, 0, 0);
					up = Vector(0, 0, 1);
				break;
				case "zoom-in":
					location = _location.mul(0.8);
				break;
				case "zoom-out":
					location = _location.mul(1.25);
				break;
				case "mode-wire-solid":
					mode = RenderMode.WIRE_SOLID;
				break;
				case "mode-wire":
					mode = RenderMode.WIRE;
				break;
				case "mode-solid":
					mode = RenderMode.SOLID;
				break;
			}
		}

		private void action_callback_actions(Gtk.Action action) {
			message("action emitted: %s", action.name);
			do_action(action.name);
		}

		public override void realize() {
			message("realize");
			base.realize();
			assert(WidgetGL.gl_begin(this));

			float[] position = {0.0f, 0.0f, -1.0f, 0.0f};
			float[] diffuse = {0.1f, 0.1f, 0.1f, 0.1f};
			float[] ambient = {0.8f, 0.8f, 0.8f, 0.8f};
			float[] specular = {0.1f, 0.1f, 0.1f, 0.1f};
			GLfloat[] glb_ambient = {0.2f,0.2f,0.2f,1f};

			glShadeModel(GL_SMOOTH);
			glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, 1);
			glEnable(GL_NORMALIZE);

			glLightModelfv(GL_LIGHT_MODEL_AMBIENT, glb_ambient);
			glLightfv(GL_LIGHT0, GL_POSITION, position);
			glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuse);
			glLightfv(GL_LIGHT0, GL_AMBIENT, ambient);
			glLightfv(GL_LIGHT0, GL_SPECULAR, specular);

			glEnable(GL_LIGHTING);
			glEnable(GL_LIGHT0);
			glEnable(GL_DEPTH_TEST);

			glPolygonMode(GL_FRONT, GL_LINE);
			glPolygonMode(GL_BACK, GL_FILL);

			float[] mf_diffuse = {1f, 1f, 1f, 1.0f};
			float[] mf_ambient = {1f, 1f, 1f, 1.0f};
			float[] mf_specular = {1f, 1f, 1f, 1.0f};

			float[] mb_diffuse = {0.7f, 0.7f, 0.7f, 1.0f};
			float[] mb_ambient = {0.7f, 0.7f, 0.7f, 1.0f};
			float[] mb_specular = {0.7f, 0.7f, 0.7f, 1.0f};

			glMaterialfv(GL_BACK, GL_AMBIENT, mb_ambient);
			glMaterialfv(GL_BACK, GL_DIFFUSE, mb_diffuse);
			glMaterialfv(GL_BACK, GL_SPECULAR, mb_specular);

			glMaterialfv(GL_FRONT, GL_AMBIENT, mf_ambient);
			glMaterialfv(GL_FRONT, GL_DIFFUSE, mf_diffuse);
			glMaterialfv(GL_FRONT, GL_SPECULAR, mf_specular);

			glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
			glClearDepth(1.0);

			glViewport(0, 0, 
				(GLsizei)allocation.width,
				(GLsizei)allocation.height);


			glMatrixMode(GL_PROJECTION);

			glLoadIdentity();


			gluPerspective(45,
			(GLdouble)allocation.width/ (GLdouble)allocation.height,
		               	   10, 1000);

			rerender();
			glFlush();

			WidgetGL.gl_end(this);
		}
		public override bool configure_event(Gdk.EventConfigure event) {
			message("configure");
			assert(WidgetGL.gl_begin(this));

			glMatrixMode(GL_PROJECTION);

			glLoadIdentity();
			gluPerspective(40,
			(GLdouble)allocation.width/ (GLdouble)allocation.height,
		               	   0.01, 1000);


			glViewport(0, 0, 
				(GLsizei)allocation.width,
				(GLsizei)allocation.height);


			WidgetGL.gl_end(this);
			return true;
		}

		public override bool expose_event(Gdk.EventExpose event) {
			assert(WidgetGL.gl_begin(this));
			Gdk.GLDrawable drawable = WidgetGL.get_gl_drawable(this);

			drawable.wait_gdk();

			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();

			Vector gl_location = _location.add(_target);
			gluLookAt(gl_location.x, gl_location.y, gl_location.z,
					target.x, target.y, target.z, up.x, up.y, up.z);

			if(scence_id != 0) {
				renderer.execute(scence_id);
			}
			if(run != null) {
				tracer.render(run);
			}
			if(!WidgetGL.gl_swap(this)) {
				glFlush();
			}
			WidgetGL.gl_end(this);
			return true;
		}

	}
}
internal static void set_track_color(Track t, double r, double g, double b) {
	t.set_double("r", r);
	t.set_double("g", g);
	t.set_double("b", b);
}
internal static void get_track_color(Track t, out double r, out double g, out double b) {
	r = t.get_double("r");
	g = t.get_double("g");
	b = t.get_double("b");
}
internal static unowned List<Vertex> get_track_history(Track t) {
	return (List<Vertex>)t.get_pointer("history");
}
internal static void push_track_history(Track t, Vertex v) {
	unowned List<Vertex> hist = (List<Vertex>) t.get_pointer("history");
	Vertex newv = t.clone_vertex(v);
	hist.prepend((owned)newv);
	t.steal_pointer("history");
	t.set_pointer("history", hist, g_list_free);
}
