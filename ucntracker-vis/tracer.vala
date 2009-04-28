using GLib;
using Gtk;
using GL;
using GLU;
using Math;

using UCNTracker;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	internal class Tracer {
		public Tracer() {}
		public void render(Run run) {
			foreach (Track track in run.tracks) {
				double r, g, b;
				int i;
				get_track_color(track, out r, out g, out b);
				glBegin(GL_LINE_STRIP);
				glColor3d(r, g, b);
				i = 0;
				foreach (Vertex vertex in get_track_history(track)) {
					glVertex3f ((GLfloat)vertex.position.x,
						        (GLfloat)vertex.position.y,
						        (GLfloat)vertex.position.z);
					i++;
				}
				glEnd();
				glPointSize(4.0f);
				glBegin(GL_POINTS);
				i = 0;
				foreach (Vertex vertex in get_track_history(track)) {
					glVertex3f ((GLfloat)vertex.position.x,
						        (GLfloat)vertex.position.y,
						        (GLfloat)vertex.position.z);
					i++;
				}
				glEnd();
			}
		}
	}
}
