using GLib;
using Gtk;
using GL;
using GLU;
using Math;

using UCNTracker;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class VertexEditor: Gtk.Table {
		Gtk.Entry v = new Gtk.Entry();
		Gtk.Entry p = new Gtk.Entry();
		Gtk.Label vlabel = new Gtk.Label.with_mnemonic("_Velocity");
		Gtk.Label plabel = new Gtk.Label.with_mnemonic("_Position");
		construct {
			resize(2,3);
			this.homogeneous = false;
			this.attach(plabel, 0, 1, 0, 1, Gtk.AttachOptions.SHRINK, Gtk.AttachOptions.SHRINK, 0, 0);
			plabel.set_mnemonic_widget(p);
			this.attach_defaults(p, 1, 2, 0, 1);
			this.attach(vlabel, 0, 1, 1, 2, Gtk.AttachOptions.SHRINK, Gtk.AttachOptions.SHRINK, 0, 0);
			vlabel.set_mnemonic_widget(v);
			this.attach_defaults(v, 1, 2, 1, 2);
			this.show_all();
		}
		private Vector _velocity = Vector(0, 0, 0);
		private Vector _position = Vector(0, 0, 0);
		public Vector velocity {
			get {
				_velocity.parse(v.text);
				return _velocity;
			}
		}
		public Vector position {
			get {
				_position.parse(p.text);
				return _position;
			}
		}
	}
}
