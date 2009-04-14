using GLib;
using Math;
using Vala.Runtime;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Torus: Primitive , Buildable {
		private double _outer_radius = 0.0;
		public double outer_radius {
			get { return _outer_radius;}
			set { _outer_radius = value; bounding_radius = value;}
		}
		public double inner_radius {get; set;}
		public override double sfunc(Vector point) {
			Vector p = point;
			world_to_body(ref p);
			double d = p.norm();
			double rc = (_inner_radius + _outer_radius)/2.0;
			double r = (_outer_radius - _inner_radius)/2.0;
			double dn = sqrt(p.x * p.x + p.y * p.y);
			return sqrt((dn - rc)*(dn - rc) + p.z * p.z) - r;
		}
	}
}
