using GLib;
using Gtk;
using GL;
using GLU;
using Math;

using UCNTracker.Geometry;
using UCNTracker.Device;
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
					_run.track_motion_notify -= track_motion_notify;
					_run.run_motion_notify -= run_motion_notify;
					_run.track_added_notify -= track_added_notify;
				}
				_run = value;
				if(_run != null) {
					_run.track_motion_notify += track_motion_notify;
					_run.run_motion_notify += run_motion_notify;
					_run.track_added_notify += track_added_notify;
				}
			}
		}
		private int track_counter = 0;
		private void track_motion_notify(Run obj, Track track, Vertex? prev) {
			/* do nothing*/
		//	message("track_counter == %d", track_counter++);
		}
		private int run_counter = 0;
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
		construct {
		Gdk.GLConfig config = new Gdk.GLConfig.by_mode (
		                  Gdk.GLConfigMode.RGB |
		                  Gdk.GLConfigMode.DOUBLE |
		                  Gdk.GLConfigMode.DEPTH);

		Gtk.WidgetGL.set_gl_capability (this,
		             config, null, true,
		             Gdk.GLRenderType.RGBA_TYPE);
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
		               	   1, 100);
			glMatrixMode(GL_MODELVIEW);
			WidgetGL.gl_end(this);
			return true;
		}
		public override bool expose_event(Gdk.EventExpose event) {
			message("expose");
			assert(WidgetGL.gl_begin(this));
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			glLoadIdentity();

			gluLookAt(80, 0, 0, 0, 0, 0, 0, 1, 0);

			if(run != null) {
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
