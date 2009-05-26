using GLib;
using Gtk;
using GL;
using GLU;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public enum RenderMode {
		WIRE,
		DOTS,
		SOLID
	}
	internal class Renderer {

		private static Quadric quadric = new Quadric();
		private RenderMode mode = RenderMode.DOTS;
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
		private void visit_volume_maybe_solid(Volume volume, bool use_solid) {
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
					visit_surface_maybe_solid(s, use_solid);
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
		private void visit_surface_maybe_solid(Surface surface, bool use_solid) {
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
				draw_sphere(s, use_solid);
			} else
			if(surface is Torus) {
				var torus = surface as Torus;
				draw_torus(torus, use_solid);
			} else
			if(surface is Rectangle) {
				var rect = surface as Rectangle;
				draw_rectangle(rect, use_solid);
			} else
			if(surface is Circle) {
				var c = surface as Circle;
				draw_circle(c, use_solid);
			} else
			if(surface is Tube) {
				var t = surface as Tube;
				draw_tube(t, use_solid);
			}

			glPopMatrix();
			
		}

		private static void draw_tube(Tube t, bool use_solid) {
			if(use_solid) {
				quadric.QuadricDrawStyle(GLU_FILL);
			} else {
				quadric.QuadricDrawStyle(GLU_LINE);
			}
			quadric.Cylinder(t.radius, t.radius, t.length, 8, 8);
		}
		private static void draw_sphere(Sphere s, bool use_solid) {
			Gdk.GLDraw.sphere (use_solid, s.radius, 8, 8);
		}
		private static void draw_torus(Torus torus, bool use_solid) {
			Gdk.GLDraw.torus (use_solid, torus.tube_radius, torus.radius, 8, 8);
		}
		private static void draw_rectangle(Rectangle r, bool use_solid) {
			double w2 = r.width /2.0;
			double h2 = r.height /2.0;
			if(use_solid) {
				glRectd(-w2, -h2, w2, h2);
			} else {
				glBegin(GL_LINE_LOOP);
				glVertex2d(-w2, -h2);
				glVertex2d(w2, -h2);
				glVertex2d(w2, h2);
				glVertex2d(-w2, h2);
				glEnd();
			}
		}
		private static void draw_circle(Circle c, bool use_solid) {
			if(use_solid) {
			glBegin(GL_TRIANGLE_FAN);
			} else {
				glBegin(GL_LINE_LOOP);
			}
			glVertex2d(0, 0);
			for(double s = c.arc_start; s <= c.arc_end + 12.0; s += 12.0) {
				double a = s / 180.0 * Math.PI;
				glVertex2d(c.radius * Math.cos(a), c.radius * Math.sin(a));
			}
			glEnd();
		}

		private void visit_volume(Volume volume) {
			switch(mode) {
				case RenderMode.DOTS:
				case RenderMode.WIRE:
					visit_volume_maybe_solid(volume, false);
				break;
				case RenderMode.SOLID:
					visit_volume_maybe_solid(volume, true);
				break;
				
			}
		}
		private void visit_surface (Surface surface) {
			switch(mode) {
				case RenderMode.DOTS:
				case RenderMode.WIRE:
					visit_surface_maybe_solid(surface, false);
				break;
				case RenderMode.SOLID:
					visit_surface_maybe_solid(surface, true);
				break;
				
			}

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

		public uint render(Experiment e, RenderMode mode) {
			uint id = glGenLists(1);

			glMatrixMode(GL_MODELVIEW);
			glPushMatrix();
			glLoadIdentity();

			glNewList((GLuint)id, GL_COMPILE);
			this.mode = mode;
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
