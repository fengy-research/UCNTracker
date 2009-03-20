using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
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
		private double _g = 9.8;
		public double g {
			get {
				return _g;
			}
			set {
				_g = value;
				acc = _direction;
				acc.mul(_g);
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
		construct {
			acc = _direction;
			acc.mul(g);
		}
		/**
		 * pspace_pos: phase space position
		 * pspace_vel: phase space velocity
		 */
		public override void fieldfunc(Vertex pspace_pos, 
		               Vertex pspace_vel) {
			pspace_vel.velocity.x += acc.x;
			pspace_vel.velocity.y += acc.y;
			pspace_vel.velocity.z += acc.z;
		}
	}
}
	
