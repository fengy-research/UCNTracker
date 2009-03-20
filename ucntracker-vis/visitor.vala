using GLib;
using Gtk;
using GL;
using GLU;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Renderer {
		public int layer;
		public void visit_union(Union u) {
		}
		public void visit_primitive(Primitive pri) {
			if(pri is Ball) {
				Ball ball = pri as Ball;
				Gdk.GLDraw.sphere (false, ball.radius, 8, 8);
			}
		}
		public void visit_volume(Volume volume) {
			glPushMatrix();
			glTranslated(volume.center.x,
			             volume.center.y,
			             volume.center.z);
			if(volume is Ball) {
				visit_primitive(volume as Primitive);
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
