[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Box : Primitive {
		private Vector _size = Vector (0.0, 0.0, 0.0);
		
		public Rectangle top = new Rectangle.rotated(EulerAngles(0, 0, 0));
		public Rectangle bottom = new Rectangle.rotated(EulerAngles(0, 180, 0));
		public Rectangle left = new Rectangle.rotated(EulerAngles(0, 90, 0));
		public Rectangle right = new Rectangle.rotated(EulerAngles(0, -90, 0));
		public Rectangle front = new Rectangle.rotated(EulerAngles(90, 90, 0));
		public Rectangle back = new Rectangle.rotated(EulerAngles(90, -90, 0));

		public Vector size {
			get { return _size; }
			set {
				_size = value;
				bounding_radius = _size.norm() / 2.0;
				message("_size = %lf %lf %lf", _size.x, _size.y, _size.z);
				message("bounding_radius = %lf", bounding_radius);
				top.center = Vector(0, 0, _size.z /2.0);
				top.width = _size.x;
				top.height = _size.y;
				bottom.center = Vector(0, 0, - _size.z /2.0);
				bottom.width = _size.x;
				bottom.height = _size.y;
				left.center = Vector(0,  -_size.y /2.0, 0);
				left.width = _size.x;
				left.height = _size.z;
				right.center = Vector(0, _size.y /2.0, 0);
				right.width = _size.x;
				right.height = _size.z;
				front.center = Vector(_size.x /2.0, 0, 0);
				front.width = _size.y;
				front.height = _size.z;
				back.center = Vector(- _size.x /2.0, 0, 0);
				back.width = _size.y;
				back.height = _size.z;
			}
		}

		construct {
			surfaces =  {
				top, bottom, left, right, front, back
			};
			front.set_name("front");
			back.set_name("back");
		}

		public Box(Vector size) {
			this.size = size;
		}
	}
}
