using UCNTracker;

/**
 * Surface Transport subroutines
 * */
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
public class Transport {
	public static void reflect(Part p, Track track,
		   Vertex leave, Vertex enter, ref bool transported) {
		transported = false;
		Vector norm = track.tail.volume.grad(leave.position);
		//message("norm = %s", norm.to_string());
		Vector reflected = leave.velocity.reflect(norm);
		//message("v_ref = %s", reflected.to_string());
		leave.velocity = reflected;
	}
	public static void diffuse(Part p, Track track,
		   Vertex leave, Vertex enter, ref bool transported) {
		transported = false;
		Vector norm = track.tail.volume.grad(leave.position);
		Vector v = Vector(0,0,0);
		do {
	//		the new velocity has to be pointing inside
			Gsl.Randist.dir_3d(UniqueRNG.rng, out v.x,
						out v.y,
						out v.z);
		} while(v.dot(norm) >= -0.01) ;
		leave.velocity = v.mul(leave.velocity.norm());
	}
	/**
	 * Transport/Reflect based on the fermi potential.
	 *
	 * When there is a reflection, Only the track itself is calculated. AKA,
	 * When transported == false, you NEED to fork the track
	 * at vertex enter.
	 * */
	public static void fermi(Part p, Track track,
		   Vertex leave, Vertex enter, ref bool transported) {
		Vector norm = leave.volume.grad(leave.position);
		double f = 8.5e-5; /* From the UCN Blue book. There is a problem with this number being here.*/
		double V = 1.0 * (enter.part.potential - leave.part.potential) * UNITS.EV;

		double E = 0.5 * track.mass * leave.velocity.norm2();
		double cos_s = leave.velocity.direction().dot(norm);
		double Ecos2_s = E * cos_s * cos_s;
//		message("mass = %lg E = %lg E+ = %lg V = %lg cos_s = %lf", track.mass,  E / (UNITS.EV * 1.0), Ecos2_s / (UNITS.EV *1.0), V / (1.0 *UNITS.EV), cos_s);

		double weight = leave.weight;
		if(Ecos2_s < V) {
			Transport.reflect(p, track, leave, enter, ref transported);
				double t = 2.0 * f * Math.sqrt(Ecos2_s/(V - Ecos2_s));
				double r = 1.0 - t;
				//message(" t = %lg r = %lg", t, r);
				leave.weight = weight * r;
				enter.weight = weight * t;
				transported = false;
			} else {
				enter.weight = weight;
				transported = true;
			}
		}
	}
}
}
