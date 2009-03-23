using GLib;
using Math;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public struct Vector {
		public double x;
		public double y;
		public double z;

		public Vector(double x, double y, double z) {
			this.x = x;
			this.y = y;
			this.z = z;
		}

		[CCode (instance_pos = 2)]
		public bool parse(string foo) {
			string[] words = foo.split(" ");
			if(words == null || words.length != 3) 
				words = foo.split(",");
			if(words == null || words.length != 3) 
				return false;
			x = words[0].to_double();
			y = words[1].to_double();
			z = words[2].to_double();
			return true;
		}

		public bool equal(Vector v) {
			/*FIXME: magic number should be controlable*/
			return distance(v) < 1.0e-6; 
		}

		/***
		 * Mirror a vector
		 * V' = 2 (V * A) A - V
		 **********/
		public void mirror (Vector axis) {
			double va = 2.0 * axis.dot(this);
			x = va * axis.x - x;
			y = va * axis.y - y;
			z = va * axis.z - z;
		}

		/***
		 * Reflect a vector according to the norm direction
		 * of a given surface.
		 * V' = - (2 (V * A) A - V)
		 **********/
		public void reflect (Vector n) {
			double va = 2.0 * n.dot(this);
			x -= va * n.x;
			y -= va * n.y;
			z -= va * n.z;
		}

		public double norm() {
			return sqrt(norm2());
		}

		public double norm2() {
			return x*x + y*y + z*z;
		}

		public double dot(Vector v) {
			return x * v.x + y * v.y + z * v.z;
		}

		public void mul(double s) {
			this.x *= s;
			this.y *= s;
			this.z *= s;
		}
		public Vector cross(Vector v) {
			/*not used yet*/
			Vector rt = Vector(
			    y * v.z - z * v.y,
			    z * v.x - x * v.z,
			    x * v.y - y * v.x);
			return rt;
		}
		public double distance(Vector v) {
			double dx = v.x - x;
			double dy = v.y - y;
			double dz = v.z - z;
			return sqrt(dx * dx + dy * dy + dz * dz);
		}

		public void rotate_i(EulerAngles r) {
			r.q.conj();
			Vector rs = r.q.rotate_vector(this);
			this = rs;
			r.q.conj();
		}

		public void translate_i(Vector a) {
			x -= a.x;
			y -= a.y;
			z -= a.z;
		}

		public void rotate(EulerAngles r) {
			Vector rs = r.q.rotate_vector(this);
			this = rs;
		}

		public void translate(Vector a) {
			x += a.x;
			y += a.y;
			z += a.z;
		}
		public string to_string(string format="%lf %lf %lf") {
			return format.printf(x, y, z);
		}
	}

	public struct Quaternion {
		/*All fields read-only!*/
		public double w;
		public Vector v;
		private int error_count = 0;
		private double t2;
		private double t3;
		private double t4;
		private double t5;
		private double t6;
		private double t7;
		private double t8;
		private double t9;
		private double t10;
		private bool dirty = true;
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
			return atan2(w, v.norm());
			return acos(w) * 2.0;
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

	public struct EulerAngles {
		/***
		 * rotation from x y z -> X Y Z.
		 * intersection between xy and XY is the 'line of nodes'
		 * Refer to wikepedia: Euler_angles.
		 */
		public double alpha; // between x and the line of nodes.
		public double beta;  // between z and Z
		public double gamma; // between the line of nodes X
		/* q should be readonly*/
		public Quaternion q;

		public EulerAngles(double alpha, double beta, double gamma) {
			this.alpha = alpha;
			this.beta = beta;
			this.gamma = gamma;
			update_q();
		}

		[CCode (instance_pos = 2)]
		public bool parse(string foo) {
			string[] words = foo.split(" ");
			if(words == null || words.length != 3) 
				words = foo.split(",");
			if(words == null || words.length != 3) 
				return false;
			alpha = words[0].to_double();
			beta = words[1].to_double();
			gamma = words[2].to_double();
			update_q();
			return true;
		}

		/* update the quaternion */
		private void update_q() {
			q = Quaternion.from_rotation(Vector(0, 0, 1), alpha);
			q.mul(Quaternion.from_rotation(Vector(1, 0, 0), beta));
			q.mul(Quaternion.from_rotation(Vector(0, 0, 1), gamma));
			q.normalize();
		}
		public string to_string(string format="%lf %lf %lf") {
			return format.printf(alpha, beta, gamma);
		}
	}
}
