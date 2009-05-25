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

		Quadric quadric = new Quadric();
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
		private void visit_volume_solid(Volume volume, bool use_solid) {
			glPushMatrix();
			EulerAngles e = volume.rotation;
			Vector axis = e.q.get_axis();
			double angle = e.q.get_angle();
			message("axis = %s angle = %lf", axis.to_string(), angle);
			glTranslated(volume.center.x,
			             volume.center.y,
			             volume.center.z);
			glRotated(angle * 180.0 / Math.PI, axis.x, axis.y, axis.z);

			if(use_solid) {
				quadric.QuadricDrawStyle(GLU_FILL);
			} else {
				quadric.QuadricDrawStyle(GLU_LINE);
			}
			if(volume is Ball) {
				Ball ball = volume as Ball;
				Gdk.GLDraw.sphere (use_solid, ball.radius, 8, 8);
			} else
			if(volume is Donut) {
				Donut torus = volume as Donut;
				Gdk.GLDraw.torus (use_solid, 
				torus.tube_radius, 
				torus.radius, 
				              8, 8);
			} else
			if(volume is Box) {
				Box box = volume as Box;
				glScaled(box.size.x, box.size.y, box.size.z);
				Gdk.GLDraw.cube (use_solid, 1.0);
			} else
			if(volume is Cylinder) {
				Cylinder c = volume as Cylinder;
				quadric.Cylinder(c.radius, c.radius, c.length, 8, 8);
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
		private void visit_volume(Volume volume) {
			switch(mode) {
				case RenderMode.DOTS:
					glBegin(GL_POINTS);
					for(int i =0; i< 200; i++) {
						Vector v = volume.sample(true);
						glVertex3d(v.x, v.y, v.z);
					}
					glEnd();
				break;
				case RenderMode.WIRE:
					visit_volume_solid(volume, false);
				break;
				case RenderMode.SOLID:
					visit_volume_solid(volume, true);
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
		private void visit_experiment(Experiment e) {
			foreach(Part p in e.parts) {
				visit_part(p);
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
