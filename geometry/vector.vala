using GLib;
using Math;

public struct Vector {
	public double x;
	public double y;
	public double z;
	public Vector clone() {
		return this;
	}
	public void rotate(EulerAngles r) {
		double ca = cos(r.alpha);
		double sa = sin(r.alpha);
		double cb = cos(r.beta);
		double sb = sin(r.beta);
		double cg = cos(r.gamma);
		double sg = sin(r.gamma);
		Vector tmp = {0.0, 0.0, 0.0};
		tmp.x = ( ca * cg - sa * cb *sg) * x + 
			   (-ca * sg - sa * cb *cg) * y +
			   ( sb * sa ) * z;
		tmp.y = ( sa * cg + ca * cb * sg) * x +
			   (-sa * sg + ca * cb * cg) * y +
			   (-sb * ca) * z;
		tmp.z = ( sb * sg ) * x +
			   ( sb * cg ) * y +
			   ( cb ) * z;
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
	/**
	 * transform the vector by successively applying:
	 * zoom z
	 * rotation r,
	 * translation a
	 */ 
	public void transform(Vector zm, EulerAngles r, Vector a) {
		zoom(zm);
		rotate(r);
		translate(a);
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
}
