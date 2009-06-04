using UCNTracker;

private void check_vectors(Vector v1, Vector v2, Vector v3) {
	Quaternion qXY = Quaternion.from_two_vectors(v1, v2);
	Vector v4 = qXY.rotate_vector(v3);
	message("cos(angle) = %lf", Math.cos(qXY.get_angle()));
	message("%lf == %lf", v2.dot(v1)/v2.norm()/v1.norm(), v4.dot(v3)/v4.norm() /v3.norm());
}
public int main(string[] args) {

	UCNTracker.init(ref args);

	Vector X = Vector(1, 0, 1);
	Vector Y = Vector(0, 1, 1);
	Vector Z = Vector(1, 0, 1);

	check_vectors(X, Y, Z);
	return 0;
}
