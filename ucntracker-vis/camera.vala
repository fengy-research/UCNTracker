using GLib;
using Gtk;
using GL;
using GLU;
using Math;

using UCNTracker;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Camera: Gtk.DrawingArea {
		private Run _run;
		private uint scence_id;
		private Renderer renderer = new Renderer();
		private Gtk.Menu popup = null;
		private Gtk.UIManager ui = new Gtk.UIManager();

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
					if(scence_id != 0) {
						renderer.delete(scence_id);
						scence_id = 0;
					}
					message("scence_id = %u", scence_id);
				}
			}
		}

		private int run_counter = 0;

		public bool use_solid {get; set;}

		private void run_motion_notify(Run obj) {
			foreach (Track track in run.tracks) {
				push_track_history(track, track.tail);
			}
			queue_draw();
		}
		private void track_added_notify(Run obj, Track track) {
			set_track_color(track,
				UCNTracker.Random.uniform(),
				UCNTracker.Random.uniform(),
				UCNTracker.Random.uniform());
		}
		//workaround bg 576122:
		private Vector _location = Vector(80, 0, 0);
		private Vector _target = Vector(0, 0, 0);
		private Vector _up = Vector(0, 0, 1);

		public Vector location {
			get {return _location;} 
			set {_location = value;}
		}
		public Vector target {
			get {return _target;} 
			set {_target = value;}
		}
		public Vector up {
			get {return _up;} 
			set {_up = value;}
		}

		private static const Gtk.ActionEntry[] ACTIONDEF = {
			{"popup", null, "Popup", null, null, action_callback_view},
			{"view", null, "View", null, null, action_callback_view},
			{"view-top", null, "Top", null, null, action_callback_view},
			{"view-bottom", null, "bottom", null, null, action_callback_view},
			{"view-left", null, "Left", null, null, action_callback_view},
			{"view-right", null, "Right", null, null, action_callback_view},
			{"view-front", null, "Front", null, null, action_callback_view},
			{"view-back", null, "Back", null, null, action_callback_view}
		};
		private static const string UIDEF = """
<ui>
<popup name="Popup" action="popup">
	<menu action="view">
		<menuitem action="view-top"/>
		<menuitem action="view-bottom"/>
		<menuitem action="view-left"/>
		<menuitem action="view-right"/>
		<menuitem action="view-front"/>
		<menuitem action="view-back"/>
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
			Gdk.GLConfig config = new Gdk.GLConfig.by_mode (
		                  	  Gdk.GLConfigMode.RGBA |
		                  	  Gdk.GLConfigMode.DOUBLE
		                  	  );

		                  //	  Gdk.GLConfigMode.DEPTH);

			Gtk.WidgetGL.set_gl_capability (this,
		             	 config, null, true,
		             	 Gdk.GLRenderType.RGBA_TYPE);
			Gtk.ActionGroup ag = new Gtk.ActionGroup("ViewActions");
			ag.add_actions(ACTIONDEF, this);
			ui.insert_action_group(ag, 0);
			ui.add_ui_from_string(UIDEF , -1);
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
			int dy = drag_end_y - drag_start_y;
			int dx = drag_end_x - drag_start_x;
			switch(event.button) {
				case 1:
					Quaternion q = Quaternion.from_rotation(
							up, (double)dx/100.0);
					_location = q.rotate_vector(_location);
					message("%s", _location.to_string());
				break;
				case 2:
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
					_location.mul(1.25);
				break;
				case Gdk.ScrollDirection.DOWN:
					_location.mul(0.80);
				break;
			}
			queue_draw();
			return true;
		}

		public void action_callback_view(Gtk.Action action) {
			message("action emitted: %s", action.name);
			double d = location.norm();
			switch(action.name) {
				case "view-top":
					location = Vector(0, 0, d);
					target = Vector(0, 0, 0);
					up = Vector(0, 1, 0);
				break;
				case "view-bottom":
					location = Vector(0, 0, -d);
					target = Vector(0, 0, 0);
					up = Vector(0, 1, 0);
				break;
				case "view-front":
					location = Vector(d, 0, 0);
					target = Vector(0, 0, 0);
					up = Vector(0, 0, 1);
				break;
				case "view-back":
					location = Vector(-d, 0, 0);
					target = Vector(0, 0, 0);
					up = Vector(0, 0, 1);
				break;
				case "view-left":
					location = Vector(0, -d, 0);
					target = Vector(0, 0, 0);
					up = Vector(0, 0, 1);
				break;
				case "view-right":
					location = Vector(0, d, 0);
					target = Vector(0, 0, 0);
					up = Vector(0, 0, 1);
				break;
			}
		}

		public override bool configure_event(Gdk.EventConfigure event) {
			message("configure");
			assert(WidgetGL.gl_begin(this));
			glClearDepth(1.0);
			glClear(GL_DEPTH_BUFFER_BIT);
			float[] light = {0.0f, 0.0f, 20.0f, 0.0f};
			glLightfv(GL_LIGHT0, GL_POSITION, light);
		//	glEnable(GL_LIGHTING);
		//	glEnable(GL_LIGHT0);
			//glEnable(GL_DEPTH_TEST);

			glViewport(0, 0, 
				(GLsizei)allocation.width,
				(GLsizei)allocation.height);


			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			gluPerspective(45,
			(GLdouble)allocation.width/ (GLdouble)allocation.height,
		               	   0.01, 100);
			glMatrixMode(GL_MODELVIEW);
			WidgetGL.gl_end(this);
			return true;
		}

		public override bool expose_event(Gdk.EventExpose event) {
			message("expose");
			assert(WidgetGL.gl_begin(this));
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			glLoadIdentity();

			gluLookAt(location.x, location.y, location.z,
					target.x, target.y, target.z, up.x, up.y, up.z);

			if(run != null) {
				message("scence_id = %u", scence_id);
				if(scence_id == 0) {
					scence_id = renderer.render(_run.experiment, use_solid);
				}
				renderer.execute(scence_id);
				foreach (Track track in run.tracks) {
					float r = (float)track.get_double("r");
					float g = (float)track.get_double("g");
					float b = (float)track.get_double("b");
					glBegin(GL_LINE_STRIP);
					glColor3f(r, g, b);
					int i = 0;
					foreach (Vertex vertex in get_track_history(track)) {
						//if( i > 100) break;
						glVertex3f ((GLfloat)vertex.position.x,
						        	(GLfloat)vertex.position.y,
						        	(GLfloat)vertex.position.z);
						i++;
					}
					glEnd();
				}
			}
			if(!WidgetGL.gl_swap(this)) {
				glFlush();
			}
			WidgetGL.gl_end(this);
			return true;
		}

	}
}
private static void set_track_color(Track t, double r, double g, double b) {
	t.set_double("r", r);
	t.set_double("g", g);
	t.set_double("b", b);
}
private static void get_track_color(Track t, out double r, out double g, out double b) {
	r = t.get_double("r");
	g = t.get_double("g");
	b = t.get_double("b");
}
private static unowned List<Vertex> get_track_history(Track t) {
	return (List<Vertex>)t.get_pointer("history");
}
private static void push_track_history(Track t, Vertex v) {
	unowned List<Vertex> hist = (List<Vertex>) t.get_pointer("history");
	Vertex newv = v.clone();
	hist.prepend(#newv);
	t.steal_pointer("history");
	t.set_pointer("history", hist, g_list_free);
}
