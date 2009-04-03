using GLib;
using Gtk;
using GL;
using GLU;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	internal class Renderer {
		public int layer;

		Quadric quadric = new Quadric();
		private bool use_solid = false;
		public Renderer() {
		}
		private void visit_union(Union u) {
			foreach(Volume child in u.children) {
				/*FIXME: hidden surface stuff!*/
				visit_volume(child);
			}
		}
		private void visit_volume(Volume volume) {
			message("visiting volume %s", volume.get_name());
			glPushMatrix();
			EulerAngles e = volume.rotation;
			Vector axis = e.q.get_axis();
			double angle = e.q.get_angle();
			glTranslated(volume.center.x,
			             volume.center.y,
			             volume.center.z);
			glRotated(angle * 180.0 / Math.PI, axis.x, axis.y, axis.z);
			message("%lf %s", angle, axis.to_string());
			if(volume is Ball) {
				Ball ball = volume as Ball;
				Gdk.GLDraw.sphere (use_solid, ball.radius, 8, 8);
			} else
			if(volume is Box) {
				Box box = volume as Box;
				glScaled(box.size.x, box.size.y, box.size.z);
				Gdk.GLDraw.cube (use_solid, 1.0);
			} else
			if(volume is Cylinder) {
				Cylinder c = volume as Cylinder;
				glTranslated(0,
			             0,
			             -c.length/2.0);
				quadric.Cylinder(c.radius, c.radius, c.length, 8, 8);
			} else
			if(volume is Union) {
				visit_union(volume as Union);
			} else {
			critical("unknown volume type");
			Gdk.GLDraw.sphere (false, volume.bounding_radius, 8, 8);
			}
			glPopMatrix();
		}
		private void visit_field(Field f) {
			message("visiting field %s", f.get_name());
			foreach(Volume v in f.volumes) {
				visit_volume(v);
			}
		}
		private void visit_part(Part part) {
			message("visiting part %s", part.get_name());
			foreach(Volume v in part.volumes) {
				visit_volume(v);
			}
		}
		private void visit_experiment(Experiment e) {
			message("visiting experiment %s", e.get_name());
			foreach(Part p in e.parts) {
				visit_part(p);
			}
			foreach(Field f in e.fields) {
				visit_field(f);
			}
		}

		public void render(Experiment e, bool use_solid) {
			this.use_solid = use_solid;
			if(use_solid) {
				quadric.QuadricDrawStyle(GLU_FILL);
			} else {
				quadric.QuadricDrawStyle(GLU_LINE);
			}
			visit_experiment(e);
		}
	}
}
