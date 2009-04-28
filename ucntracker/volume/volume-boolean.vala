using GLib;
using Math;
using Vala.Runtime;

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
		 *   return the sum of the sfuncs of THESE childrens(those
		 *   contain the given point)
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
			double small = 1e-7;
			int small_count = 0;
			Vector body_p = world_to_body(point);
			foreach(Volume child in children) {
				double s = child.sfunc(body_p);
				if(fabs(s) < small) small_count++;
				if( s > 0.0 ) {
					if(min > s ) min = s;
				} else {
					in_or_on = true;
					sum += s;
				}
			}
			if(in_or_on) {
				/*inside some volumes*/
				/*if we are inside two or more subvolumes,
				 * and close to two surfaces,
				 * adjust the sfunc so that we are not close
				 * to zero.
				 * */
				if(small_count > 1) {
					message("common boundary detected");
					sum = sum - exp(sum * 10.0 /small);
				}
				return sum;
			} else {
				/*outside of all volumes*/
				return min;
			}
		}
	}

	public class Intersection: Volume, Buildable {
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
		 * If the point is inside all children,
		 * return the max sfunc of the children (they are all negative).
		 *
		 * If the point is outside some children,
		 * return the min sfunc of THESE children (those who doesn't contain
		 * the point).
		 *
		 *****/
		public override double sfunc(Vector point) {
			double min = double.MAX;
			double max = -double.MAX;

			bool in_or_on = true;
			Vector body_p =world_to_body(point);
			foreach(Volume child in children) {
				double s = child.sfunc(body_p);
				if( s > 0.0 ) {
					if(min > s ) min = s;
					in_or_on = false;
				} else {
					if(max < s) max = s;
				}
			}
			if(in_or_on) {
				/*inside all volumes*/
				return max;
			} else {
				/*outside of some volumes*/
				return min;
			}
		}

	}
}
