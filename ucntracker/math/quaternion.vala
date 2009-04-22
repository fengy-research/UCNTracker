using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public struct Quaternion {
		/*All fields read-only!*/
		public double w;
		public Vector v;
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
			t2 =   w * v.x;
			t3 =   w * v.y;
			t4 =   w * v.z;
			t5 =  -v.x * v.x;
			t6 =   v.x * v.y;
			t7 =   v.x * v.z;
			t8 =  -v.y * v.y;
			t9 =   v.y * v.z;
			t10 = -v.z * v.z;
			dirty = false;
		}
		public Quaternion.from_vector(Vector v) {
			w = 0.0;
			this.v = v;
			dirty = true;
		}
		public Quaternion.from_rotation(Vector axis, double angle) {
			w = cos(angle/2.0);
			double s = sin(angle/2.0);
			v.x = axis.x * s;
			v.y = axis.y * s;
			v.z = axis.z * s;
			dirty = true;
		}
		public double get_angle() {
			return 2.0 * atan2(v.norm(), w);
		}
		public Vector get_axis() {
			Vector rt = v;
			double n = v.norm();
			/* if there is no rotation*/
			if(n == 0.0) return Vector(0.0, 0.0, 1.0);
			rt.mul(1.0/n);
			return rt;
		}
		public void mul(Quaternion q) {
			double w0 = (w * q.w - v.x * q.v.x - v.y * q.v.y - v.z * q.v.z);
			double x0 = (w * q.v.x + v.x * q.w + v.y * q.v.z - v.z * q.v.y);
			double y0 = (w * q.v.y - v.x * q.v.z + v.y * q.w + v.z * q.v.x);
			double z0 = (w * q.v.z + v.x * q.v.y - v.y * q.v.x + v.z * q.w);
			w = w0;
			v.x = x0;
			v.y = y0;
			v.z = z0;
			error_count ++;
			if(error_count > 100) normalize();
			dirty = true;
		}
		public void conj() {
			update_t();
			v.x = -v.x;
			v.y = -v.y;
			v.z = -v.z;
			t2 = -t2;
			t3 = -t3;
			t4 = -t4;
		}
		public void normalize() {
			double norm2 = w * w + v.norm2();
			double norm = sqrt(norm2);
			w /= norm;
			v.x /= norm;
			v.y /= norm;
			v.z /= norm;
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
	}
}
