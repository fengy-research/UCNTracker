using GLib;
using Math;
using Vala.Runtime;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class GravityField: Field, Buildable {
		private double _g = 9.800;
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
		public override void fieldfunc(Track track, 
		               Vertex Q, 
		               Vertex dQ) {
			dQ.velocity.x += acc.x;
			dQ.velocity.y += acc.y;
			dQ.velocity.z += acc.z;
		}
	}
}
