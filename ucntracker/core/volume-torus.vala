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
			double d = point.distance(center);
			double d_inner = _inner_radius - d;
			double d_outer = d - _outer_radius;

			/* inside inner*/
			if(d_inner > 0.0) return d_inner;
			/* outside outer */
			if(d_outer > 0.0) return d_outer;
			/* inside the torus, use the value that is closer to zero*/
			if(d_inner < d_outer) return d_outer;
			return d_inner;
		}
	}
}
