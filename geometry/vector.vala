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
		string[] words = foo.split(",");
		message("%s", foo);
		if(words == null || words.length != 3) {
			return false;
		}
		x = words[0].to_double();
		y = words[1].to_double();
		z = words[2].to_double();
		return true;
	}
	public bool equal(Vector v) {
		/*FIXME: magic number should be controlable*/
		return distance(v) < 1.0e-6; 
	}
	public double distance(Vector v) {
		double dx = v.x - x;
		double dy = v.y - y;
		double dz = v.z - z;
		return sqrt(dx * dx + dy * dy + dz * dz);

	}
	public void rotate_i(EulerAngles r) {
		Vector tmp = {
			r.matrix[0,0] * x +
			r.matrix[1,0] * y +
			r.matrix[2,0] * z,
			r.matrix[0,1] * x +
			r.matrix[1,1] * y +
			r.matrix[2,1] * z,
			r.matrix[0,2] * x +
			r.matrix[1,2] * y +
			r.matrix[2,2] * z
		};
		x = tmp.x;
		y = tmp.y;
		z = tmp.z;
	}
	public void translate_i(Vector a) {
		x -= a.x;
		y -= a.y;
		z -= a.z;
	}
	public void zoom_i(Vector zm) {
		x /= zm.x;
		y /= zm.y;
		z /= zm.z;
	}
	public void rotate(EulerAngles r) {
		Vector tmp = {
			r.matrix[0,0] * x +
			r.matrix[0,1] * y +
			r.matrix[0,2] * z,
			r.matrix[1,0] * x +
			r.matrix[1,1] * y +
			r.matrix[1,2] * z,
			r.matrix[2,0] * x +
			r.matrix[2,1] * y +
			r.matrix[2,2] * z
		};
		x = tmp.x;
		y = tmp.y;
		z = tmp.z;
	}
	public void translate(Vector a) {
		x += a.x;
		y += a.y;
		z += a.z;
	}
	public void zoom(Vector zm) {
		x *= zm.x;
		y *= zm.y;
		z *= zm.z;
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
	public double[3,3] matrix;
	public EulerAngles(double alpha, double beta, double gamma) {
		this.alpha = alpha;
		this.beta = beta;
		this.gamma = gamma;
		this.matrix = new double[3,3];
		double ca = cos(alpha);
		double sa = sin(alpha);
		double cb = cos(beta);
		double sb = sin(beta);
		double cg = cos(gamma);
		double sg = sin(gamma);
		matrix[0,0] = ca * cg - sa * cb * sg;
		matrix[0,1] = -ca * sg - sa * cb * cg;
		matrix[0,2] = sb * sa;
		matrix[1,0] = sa * cg + ca * cb * sg;
		matrix[1,1] = -sa * sg + ca * cb * cg;
		matrix[1,2] = - sb * ca;
		matrix[2,0] = sb * sg;
		matrix[2,1] = sb * cg;
		matrix[2,2] = cb;
	}
	[CCode (instance_pos = 2)]
	public bool parse(string foo) {
		string[] words = foo.split(",");
		if(words == null || words.length != 3) return false;
		alpha = words[0].to_double();
		beta =	words[1].to_double();
		gamma = words[2].to_double();
		return true;
	}
}
}
