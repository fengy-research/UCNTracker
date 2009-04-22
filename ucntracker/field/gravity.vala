using GLib;
using Math;
using Vala.Runtime;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class GravityField: Field, Buildable {
		private double _g = 9.8;
		public double g {
			get {
				return _g;
			}
			set {
				_g = value;
				acc = _direction.mul(g);
			}
		}
		private Vector _direction = Vector(0.0, 0.0, -1.0);
		public Vector direction {
			get {
				return _direction;
			}
			set {
				_direction = value;
				acc = _direction.mul(g);
			}
		}
		public Vector acc {get; private set;}
		construct {
			acc = _direction.mul(g);
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
