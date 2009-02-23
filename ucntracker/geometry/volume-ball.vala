using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Geometry {
	public class Ball : Volume, Buildable {
		private double _radius;
		public double radius {
		get { return _radius; } 
		set { _radius = value; bounding_radius = value;}
		}
		public override double sfunc(Vector point) {
			return point.distance(center) - radius;
		}	
	}

}
}
