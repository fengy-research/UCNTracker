[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class AccelField: Field {
		private double _accel = 9.800;
		public double accel {
			get {
				return _accel;
			}
			set {
				_accel = value;
				acc = _direction.mul(_accel);
			}
		}
		private Vector _direction = Vector(0.0, 0.0, -1.0);
		public Vector direction {
			get {
				return _direction;
			}
			set {
				_direction = value;
				acc = _direction.mul(_accel);
			}
		}
		public Vector acc {get; private set;}
		construct {
			acc = _direction.mul(_accel);
		}

		public override bool fieldfunc(Track track, 
		               Vertex Q, 
		               Vertex dQ) {
			dQ.velocity.x += acc.x;
			dQ.velocity.y += acc.y;
			dQ.velocity.z += acc.z;
			return true;
		}
	}
}
