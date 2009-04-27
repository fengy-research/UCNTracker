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
		public Vector mirror (Vector axis) {
			double va = 2.0 * axis.dot(this);
			return Vector(va * axis.x - x, va * axis.y - y, va * axis.z - z);
		}

		/***
		 * Reflect a vector according to the norm direction
		 * of a given surface.
		 * V' = - (2 (V * A) A - V)
		 **********/
		public Vector reflect (Vector n) {
			double va = 2.0 * n.dot(this);
			return Vector(x - va * n.x, y - va * n.y, z - va * n.z);
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

		public Vector mul(double s) {
			return Vector(x * s, y * s, z * s);
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

		public Vector add(Vector a) {
			return Vector(a.x + x, a.y + y, a.z + z);
		}
		
		public Vector direction() {
			double norm = norm();
			if(norm != 0.0)
				return Vector(x/norm, y/norm, z/norm);
			else return Vector(0.0, 0.0, 1.0);
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


}
