[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public struct Quaternion {
		/*All fields read-only!*/
		public double w;
		public double x;
		public double y;
		public double z;
		private int error_count;
		private double t2;
		private double t3;
		private double t4;
		private double t5;
		private double t6;
		private double t7;
		private double t8;
		private double t9;
		private double t10;
		private bool dirty;
		private void update_t() {
			if(!dirty) return;
			t2 =   w * x;
			t3 =   w * y;
			t4 =   w * z;
			t5 =  -x * x;
			t6 =   x * y;
			t7 =   x * z;
			t8 =  -y * y;
			t9 =   y * z;
			t10 = -z * z;
			dirty = false;
		}
		public Quaternion(double w, double x, double y, double z) {
			this.w = w;
			this.x = x;
			this.y = y;
			this.z = z;
			dirty = true;
		}
		/**
		 * Create a quaternion based on a rotation that rotate
		 * v1 to v2
		 * */
		public Quaternion.from_two_vectors(Vector v1, Vector v2) {
			double n1 = v1.norm();
			double n2 = v2.norm();
			Vector k = v1.cross(v2);
			double normk = k.norm();
			Vector axis = k.mul(1.0 / normk);
			double angle = Math.acos(v1.dot(v2)/ (n1 * n2));
			w = Math.cos(angle/2.0);
			double s = Math.sin(angle/2.0);
			x = axis.x * s;
			y = axis.y * s;
			z = axis.z * s;
			dirty = true;
		}
		public Quaternion.from_vector(Vector v) {
			w = 0.0;
			this.x = v.x;
			this.y = v.y;
			this.z = v.z;
			dirty = true;
		}
		public Quaternion.from_rotation(Vector axis, double angle) {
			w = Math.cos(angle/2.0);
			double s = Math.sin(angle/2.0);
			x = axis.x * s;
			y = axis.y * s;
			z = axis.z * s;
			dirty = true;
		}
		public double get_angle() {
			return 2.0 * Math.atan2(Math.sqrt(x*x + y*y + z*z), w);
		}
		public Vector get_axis() {
			Vector rt = Vector(x, y, z);
			double n = Math.sqrt(x*x + y*y + z*z);
			/* if there is no rotation*/
			if(n == 0.0) return Vector(0.0, 0.0, 1.0);
			rt.mul(1.0/n);
			return rt;
		}
		public void mul(Quaternion q) {
			double w0 = (w * q.w - x * q.x - y * q.y - z * q.z);
			double x0 = (w * q.x + x * q.w + y * q.z - z * q.y);
			double y0 = (w * q.y - x * q.z + y * q.w + z * q.x);
			double z0 = (w * q.z + x * q.y - y * q.x + z * q.w);
			w = w0;
			x = x0;
			y = y0;
			z = z0;
			error_count ++;
			if(error_count > 100) normalize();
			dirty = true;
		}
		public void conj() {
			update_t();
			x = -x;
			y = -y;
			z = -z;
			t2 = -t2;
			t3 = -t3;
			t4 = -t4;
		}
		public void normalize() {
			double norm2 = w * w + x*x + y*y + z*z;
			double norm = Math.sqrt(norm2);
			w /= norm;
			x /= norm;
			y /= norm;
			z /= norm;
			error_count = 0;
			update_t();
		}
		public Vector rotate_vector(Vector v) {
			update_t();
			return Vector(
			2.0*( (t8 + t10)*v.x + (t6 -  t4)*v.y + (t3 + t7)*v.z ) + v.x,
			2.0*( (t4 +  t6)*v.x + (t5 + t10)*v.y + (t9 - t2)*v.z ) + v.y,
			2.0*( (t7 -  t3)*v.x + (t2 +  t9)*v.y + (t5 + t8)*v.z ) + v.z
			);
		}
		public string to_string() {
			return "%lf %lf %lf %lf".printf(w, x, y, z);
		}
	}
}
