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
namespace TransportChannels {
	/**
	 * Transport/Reflect based on the fermi potential.
	 *
	 * returns true if need to fork a new track at Vertex enter;
	 * */
	public static bool fermi(Track track,
		   Vertex leave, Vertex enter) {
		Vector norm = leave.volume.grad(leave.position);
		double DV = (enter.part.potential.V - leave.part.potential.V) * UNITS.EV;
		double DW = (enter.part.potential.f * enter.part.potential.V 
		           - leave.part.potential.f * leave.part.potential.V) * UNITS.EV;

		if(DV == 0.0) {
			/* Same potential, directly transport to the next part.*/
			enter.velocity = leave.velocity;
			enter.weight = leave.weight;
			return false;
		}
		double f = DW / DV;
		
		if(f > 0.01) {
			critical("f = %lf is too large, the approximation here might fail. Refer to Ultra-Cold Neutrons, RDS, P25 eq 2.67.", f);
		}

		double E = 0.5 * track.mass * leave.velocity.norm2();
		double cos_s = leave.velocity.direction().dot(norm);
		double Ecos2_s = E * cos_s * cos_s;

		double weight = leave.weight;
		if(Ecos2_s < DV) {
			/* mu(E, theta) is the wall loss probability per bounce.(2.68) */
			double mu = 2.0 * f * Math.sqrt(Ecos2_s/(DV - Ecos2_s));
			double R2 = 1.0 - mu;
			leave.weight = weight * R2;

			leave.velocity = leave.velocity.reflect(norm);

			enter.weight = weight * mu;
			return true;
		} else {
			return false;
		}
	}
}
}
