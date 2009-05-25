[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/**
	 * A Transformable can be either a Volume or a Surface
	 *
	 * A geometryic shape in UCNTracker is actually a transformable.
	 * AKA, it can be applied by a shift, specified by the new vector of
	 * the center, and then applied by a rotation, specified by a set of 
	 * Euler Angles.
	 *
	 * */
	public class Transformable: Object {

		public Vector center {get; set; }

		public EulerAngles rotation { get; set; }
		
		construct {
			rotation = EulerAngles(0.0, 0.0, 0.0);
			center = Vector(0.0, 0.0, 0.0);
		}
		public Vector world_to_body(Vector point) {
			Vector rt = point;
			rt.translate_i(center);
			rt.rotate_i(rotation);
			return rt;
		}

		public Vector body_to_world(Vector point) {
			Vector rt = point;
			rt.rotate(rotation);
			rt.translate(center);
			return rt;
		}
		
	}
}
