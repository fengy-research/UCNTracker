using GLib;
using Gtk;
using GL;
using GLU;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	internal class Renderer {
		public int layer;
		public void visit_union(Union u) {
		}
		Quadric quadric = new Quadric();
		public Renderer() {
			
			quadric.QuadricDrawStyle(GLU_LINE);
		}
		public void visit_volume(Volume volume) {
			glPushMatrix();
			EulerAngles e = volume.rotation;
			Vector axis = e.q.get_axis();
			double angle = e.q.get_angle();
			glRotated(angle, axis.x, axis.y, axis.z);
			glTranslated(volume.center.x,
			             volume.center.y,
			             volume.center.z);
			if(volume is Ball) {
				Ball ball = volume as Ball;
				Gdk.GLDraw.sphere (false, ball.radius, 8, 8);
			} else
			if(volume is Box) {
				Box box = volume as Box;
				glScaled(box.size.x, box.size.y, box.size.z);
				Gdk.GLDraw.cube (false, 1.0);
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
		public void visit_field(Field f) {
			foreach(Volume v in f.volumes) {
				visit_volume(v);
			}
		}
		public void visit_part(Part part) {
			foreach(Volume v in part.volumes) {
				visit_volume(v);
			}
		}
		public void visit_experiment(Experiment e) {
			foreach(Part p in e.parts) {
				visit_part(p);
			}
			foreach(Field f in e.fields) {
				visit_field(f);
			}
		}
	}
}
