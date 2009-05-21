using UCNTracker;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNPhysics {
/**
 * Surface Transport subroutines.
 *
 * The routines here update the given Vertex, but never create new forks.
 * Take a special note on fermi: When the return value is false;
 * Always fork the current track on enter.
 * */
namespace Transport {
	/**
	 * Transport/Reflect based on the fermi potential.
	 *
	 * returns true if need to fork a new track at Vertex enter;
	 * */
	public static void fermi(ref Border.Event event) {
		double DV = (event.enter.part.potential.V - event.leave.part.potential.V) * UNITS.EV;
		double DW = (event.enter.part.potential.f * event.enter.part.potential.V 
		           - event.leave.part.potential.f * event.leave.part.potential.V) * UNITS.EV;

		if(DV == 0.0) {
			/* Same potential, directly transport to the next part.*/
			event.enter.velocity = event.leave.velocity;
			event.enter.weight = event.leave.weight;
			event.transported = true;
			event.forked_track = null;
			return;
		}
		double f = DW / DV;
		
		if(f > 0.01) {
			critical("f = %lf is too large, the approximation here might fail. Refer to Ultra-Cold Neutrons, RDS, P25 eq 2.67.", f);
		}

		double E = 0.5 * event.track.mass * event.leave.velocity.norm2();
		double cos_s = event.leave.velocity.direction().dot(event.normal);
		double Ecos2_s = E * cos_s * cos_s;

		double weight = event.leave.weight;
		if(Ecos2_s < DV) {
			/* mu(E, theta) is the wall loss probability per bounce.(2.68) */
			double mu = 2.0 * f * Math.sqrt(Ecos2_s/(DV - Ecos2_s));
			double R2 = 1.0 - mu;
			event.leave.weight = weight * R2;

			event.leave.velocity = event.leave.velocity.reflect(event.normal);

			event.enter.weight = weight * mu;
			event.forked_track = event.track.fork(event.track.get_type(), event.enter);
			event.transported = false;
			return;
		} else {
			event.forked_track = null;
			event.transported = true;
		}
	}
	public void reflect(ref Border.Event event) {
		Vector reflected = event.leave.velocity.reflect(event.normal);
		event.leave.velocity = reflected;
		event.transported = false;
	}
	public void diffuse(ref Border.Event event) {
		Vector v = Vector(0,0,0);
		do {
	//		the new velocity has to be pointing inside
			Gsl.Randist.dir_3d(UniqueRNG.rng, out v.x,
						out v.y,
						out v.z);
		} while(v.dot(event.normal) >= -0.01) ;
		event.leave.velocity = v.mul(event.leave.velocity.norm());
		event.transported = false;
	}
	public void absorb(ref Border.Event event) {
		event.track.terminate();
		event.transported = false;
	}
}
}
