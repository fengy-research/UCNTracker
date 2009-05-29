using GLib;
using Gtk;
using GL;
using GLU;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	internal class Renderer {

		private static Quadric quadric = new Quadric();
		public Renderer() {
		}
		private void visit_union(Union u) {
			foreach(Volume child in u.children) {
				/*FIXME: hidden surface stuff!*/
				visit_volume(child);
			}
		}
		private void visit_intersection(Intersection i) {
			foreach(Volume child in i.children) {
				/*FIXME: hidden surface stuff!*/
				visit_volume(child);
			}
		}

		private void visit_surface(Surface surface) {
			if(surface.visible == false) return;
			glPushMatrix();
			EulerAngles e = surface.rotation;
			Vector axis = e.q.get_axis();
			double angle = e.q.get_angle();
			glTranslated(surface.center.x,
			             surface.center.y,
			             surface.center.z);
			glRotated(angle * 180.0 / Math.PI, axis.x, axis.y, axis.z);
			if(surface is Sphere) {
				var s = surface as Sphere;
				draw_sphere(s);
			} else
			if(surface is Torus) {
				var torus = surface as Torus;
				draw_torus(torus);
			} else
			if(surface is Rectangle) {
				var rect = surface as Rectangle;
				draw_rectangle(rect);
			} else
			if(surface is Circle) {
				var c = surface as Circle;
				draw_circle(c);
			} else
			if(surface is Tube) {
				var t = surface as Tube;
				draw_tube(t);
			}

			glPopMatrix();
			
		}

		private static void draw_tube(Tube t) {
			quadric.Cylinder(t.radius, t.radius, t.length, 12, 12);
		}
		private static void draw_sphere(Sphere s) {
			Gdk.GLDraw.sphere (true, s.radius, 12, 12);
		}
		private static void draw_torus(Torus torus) {
			Gdk.GLDraw.torus (true, torus.tube_radius, torus.radius, 8, 8);
		}
		private static void draw_rectangle(Rectangle r) {
			double w2 = r.width /2.0;
			double h2 = r.height /2.0;
			glRectd(-w2, -h2, w2, h2);
		}
		private static void draw_circle(Circle c) {
			glBegin(GL_TRIANGLE_FAN);
			glVertex2d(0, 0);
			for(double s = c.arc_start; s <= c.arc_end + 12.0; s += 12.0) {
				double a = s / 180.0 * Math.PI;
				glVertex2d(c.radius * Math.cos(a), c.radius * Math.sin(a));
			}
			glEnd();
		}

		private void visit_volume(Volume volume) {
			if(volume.visible == false) return;
			glPushMatrix();
			EulerAngles e = volume.rotation;
			Vector axis = e.q.get_axis();
			double angle = e.q.get_angle();
			message("axis = %s angle = %lf", axis.to_string(), angle);
			glTranslated(volume.center.x,
			             volume.center.y,
			             volume.center.z);
			glRotated(angle * 180.0 / Math.PI, axis.x, axis.y, axis.z);

			if(volume is Primitive) {
				Primitive p = volume as Primitive;
				foreach(var s in p.surfaces) {
					visit_surface(s);
				}
			} else
			if(volume is Union) {
				visit_union(volume as Union);
			} else
			if(volume is Intersection) {
				visit_intersection(volume as Intersection);
			} else {
			critical("unknown volume type");
			Gdk.GLDraw.sphere (false, volume.bounding_radius, 8, 8);
			}
			glPopMatrix();
		}
		private void visit_field(Field f) {
			glColor4d(1.0, 1.0, 1.0, 0.05);
			foreach(Volume v in f.volumes) {
				visit_volume(v);
			}
		}
		private void visit_part(Part part) {
			glColor4d(1.0, 1.0, 0.0, 0.01);
			foreach(Volume v in part.volumes) {
				visit_volume(v);
			}
		}
		private void visit_foil(Foil foil) {
			glColor4d(1.0, 0.0, 0.0, 0.01);
			foreach(var s in foil.surfaces) {
				visit_surface(s);
			}
		}
		private void visit_experiment(Experiment e) {
			foreach(Part p in e.parts) {
				visit_part(p);
			}
			foreach(Foil f in e.foils) {
				visit_foil(f);
			}
			foreach(Field f in e.fields) {
				visit_field(f);
			}
		}

		public uint render(Experiment e) {
			uint id = glGenLists(1);

			glMatrixMode(GL_MODELVIEW);
			glPushMatrix();
			glLoadIdentity();

			glNewList((GLuint)id, GL_COMPILE);
			visit_experiment(e);
			glEndList();
			glPopMatrix();
			return id;
		}
		public void execute(uint scence_id) {
			glCallList((GLuint)scence_id);
		}
		public void delete(uint scence_id) {
			glDeleteLists((GLuint)scence_id, 1);
		}
	}
}
