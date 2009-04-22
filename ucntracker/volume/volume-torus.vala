using GLib;
using Math;
using Vala.Runtime;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Torus: Primitive , Buildable {
		private double _tube_radius= 0.0;
		private double _radius = 0.0;
		public double tube_radius {
			get { return _tube_radius;}
			set { _tube_radius = value; bounding_radius = _tube_radius + _radius;}
		}
		public double radius {
			get { return _radius;}
			set { _radius = value; bounding_radius = _tube_radius + _radius;}
		}

		public override double sfunc(Vector point) {
			Vector p = point;
			world_to_body(ref p);
			double dn = sqrt(p.x * p.x + p.y * p.y);
			return sqrt((dn - _radius)*(dn - _radius) + p.z * p.z) - _tube_radius;
		}
	}
}
