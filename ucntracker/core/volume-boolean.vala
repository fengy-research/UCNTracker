using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Union: Volume, Buildable {
		public List<Volume> children;
		public void add_child(Builder builder, GLib.Object child, string? type) {
			if(child is Volume) {
				Volume volume = child as Volume;
				children.prepend(volume);
				double new_radius = 
				    volume.center.norm() + volume.bounding_radius;
				if(new_radius > bounding_radius)
					bounding_radius = new_radius;
			}
		}
		/**
		 * Logic:
		 *   If the given point is inside some of the childrens,
		 *   return the sum of the sfuncs of these childrens.
		 *
		 *   If the point is outside all the childrens,
		 *   return the smallest sfunc of all these childrens.
		 *
		 * FIXME:
		 *   If two volumes taking union share the same surface,
		 *   this sfunc is going to give small values for these inside surfaces.
		 *   A clean solution would be in sense detect whether the sfunc
		 *   changes sign along some direction.. But this solution is not
		 *   easy to cleanly define in a mathematical way.
		 */
		public override double sfunc(Vector point) {
			double min = double.MAX;
			/**
			 * sum: sum of sfunc for all children that contains
			 * the point
			 * */
			double sum = 0.0;
			bool in_or_on = false;
			Vector body_p = point;
			world_to_body(ref body_p);
			foreach(Volume child in children) {
				double s = child.sfunc(body_p);
				if( s > 0.0 ) {
					if(min > s ) min = s;
				} else {
					in_or_on = true;
					sum += s;
				}
			}
			if(in_or_on) {
				/*inside some volumes*/
				return sum;
			} else {
				/*outside of all volumes*/
				return min;
			}
		}
	}
}
