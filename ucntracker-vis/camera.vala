using GLib;
using Gtk;
using GL;
using GLU;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Camera: Gtk.DrawingArea {
		private Run _run;
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

		private int run_counter = 0;

		public bool use_solid {get; set;}

		private void run_motion_notify(Run obj) {
		//	message("run_counter == %d", run_counter++);
			run_counter++;
			if(run_counter > 10) {
				run_counter = 0;
				queue_draw();
			}
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

		construct {
		this.add_events(
			Gdk.EventMask.BUTTON_MOTION_MASK |
			Gdk.EventMask.POINTER_MOTION_HINT_MASK |
			Gdk.EventMask.BUTTON_PRESS_MASK |
			Gdk.EventMask.BUTTON_RELEASE_MASK |
			Gdk.EventMask.SCROLL_MASK
		);
		Gdk.GLConfig config = new Gdk.GLConfig.by_mode (
		                  Gdk.GLConfigMode.RGB |
		                  Gdk.GLConfigMode.DOUBLE |
		                  Gdk.GLConfigMode.DEPTH);

		Gtk.WidgetGL.set_gl_capability (this,
		             config, null, true,
		             Gdk.GLRenderType.RGBA_TYPE);
		}
		private int drag_start_x = 0;
		private int drag_start_y = 0;
		private int drag_end_x = 0;
		private int drag_end_y = 0;
		public override bool button_press_event(Gdk.EventButton event) {
			get_pointer(out drag_start_x, out drag_start_y);
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
		public override bool button_release_event(Gdk.EventButton event) {
			get_pointer(out drag_end_x, out drag_end_y);
			int dy = drag_end_y - drag_start_y;
			int dx = drag_end_x - drag_start_x;
			message("%u", event.button);
			switch(event.button) {
				case 1:
					Quaternion q = Quaternion.from_rotation(
							Vector(0, 0, -1), (double)dx/100.0);
					Quaternion p = Quaternion.from_rotation(
							Vector(0, -1, 0), (double)dy/100.0);
					_location = q.rotate_vector(_location);
					_location = p.rotate_vector(_location);
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
		public override bool motion_notify_event(Gdk.EventMotion event) {
			return true;
		}
		public override bool configure_event(Gdk.EventConfigure event) {
			message("configure");
			assert(WidgetGL.gl_begin(this));
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
		private Renderer renderer = new Renderer();
		public override bool expose_event(Gdk.EventExpose event) {
			message("expose");
			assert(WidgetGL.gl_begin(this));
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			glLoadIdentity();

			gluLookAt(location.x, location.y, location.z,
					target.x, target.y, target.z, up.x, up.y, up.z);

			if(run != null) {
				renderer.render(run.experiment, use_solid);
				foreach (Track track in run.tracks) {
					float r = (float)track.get_double("r");
					float g = (float)track.get_double("g");
					float b = (float)track.get_double("b");
					glBegin(GL_POINTS);
					glColor3f(r, g, b);
					foreach (Vertex vertex in track.history.head) {
						glVertex3f ((GLfloat)vertex.position.x,
						        	(GLfloat)vertex.position.y,
						        	(GLfloat)vertex.position.z);
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
		public static void set_track_color(Track t, double r, double g, double b) {
			t.set_double("r", r);
			t.set_double("g", g);
			t.set_double("b", b);
		}
		public static void get_track_color(Track t, out double r, out double g, out double b) {
			r = t.get_double("r");
			g = t.get_double("g");
			b = t.get_double("b");
		}
	}
}