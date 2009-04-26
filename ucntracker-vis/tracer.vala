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
				/*
				foreach (Vertex vertex in get_track_history(track)) {
					//if( i > 100) break;
					//if(i % 2 != 0) continue;
					glPushMatrix();
					Vector v = Vector(0, 0, -1).cross(vertex.spin);
					double norm = v.norm();
					glRotated(asin(norm) /Math.PI * 180.0, v.x, v.y, v.z);
					glTranslated(vertex.position.x, vertex.position.y, vertex.position.z);
					Gdk.GLDraw.cone(true, 0.5, 0.5, 4, 4);
					glPopMatrix();
					i--;
				}
				*/
			}
		}
	}
}
