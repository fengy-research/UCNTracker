using GLib;
using Math;

using UCNTracker.Geometry;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Device {
	public abstract class Field: Object, Buildable {
		public List<Volume> volumes;
		public void add_child(Builder builder, GLib.Object child, string? type) {
			if(child is Volume) {
				Volume volume = child as Volume;
				volumes.prepend(child as Volume);
			} else {
				critical("expecting type %s for a child but found type %s",
					typeof(Volume).name(),
					child.get_type().name());
			}
		}
		public abstract void fieldfunc(Vertex vertex, Vertex force);
	}
	public class GField: Field, Buildable {
		public double _g = 980;
		public double g {
			get {
				return _g;
			}
			set {
				_g = value;
				acc = _direction;
				acc.mul(g);
			}
		}
		private Vector _direction = Vector(0.0, 0.0, -1.0);
		public Vector direction {
			get {
				return _direction;
			}
			set {
				_direction = value;
				acc = _direction;
				acc.mul(g);
			}
		}
		public Vector acc {get; private set;}
		public override void fieldfunc(Vertex phase_space_pos, 
		               Vertex phase_space_vel) {
			phase_space_vel.position = phase_space_pos.velocity;
			phase_space_vel.velocity = acc;
		}
	}
}
}
	
