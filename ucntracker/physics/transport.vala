using UCNTracker;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
/**
 * Surface Transport subroutines.
 *
 * The routines here update the given Vertex, but never create new forks.
 * Take a special note on fermi: When the return value is false;
 * Always fork the current track on enter.
 * */
public class Transport {
	public double diffuse_channel_size;
	public double fermi_channel_size;
	public double reflect_channel_size;
	private Track track;
	private Vertex enter;
	private Vertex leave;
	private MultiChannelRNG mcrng = new MultiChannelRNG();

	public Transport(double diffuse, double fermi, double reflect) {
		diffuse_channel_size = diffuse;
		fermi_channel_size = fermi;
		reflect_channel_size= reflect;
		mcrng.add_channel(diffuse_channel_size, this.diffuse_channel);
		mcrng.add_channel(reflect_channel_size, this.reflect_channel);
		mcrng.add_channel(fermi_channel_size, this.fermi_channel);
	}
	public bool execute(Track track, Vertex leave, Vertex enter) {
		this.track = track;
		this.leave = leave;
		this.enter = enter;
		return mcrng.execute(UniqueRNG.rng);
	}
	private bool reflect_channel() {
		reflect(track, leave);
		return false;
	}
	private bool diffuse_channel() {
		diffuse(track, leave);
		return false;
	}
	private bool fermi_channel() {
		return fermi(track, leave, enter);
	}
	public static void reflect(Track track, Vertex leave) {
		Vector norm = track.tail.volume.grad(leave.position);
		Vector reflected = leave.velocity.reflect(norm);
		leave.velocity = reflected;
	}
	public static void diffuse(Track track, Vertex leave) {
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
	public static bool fermi(Track track,
		   Vertex leave, Vertex enter) {
		Vector norm = leave.volume.grad(leave.position);
		double DV = (enter.part.material_V - leave.part.material_V) * UNITS.EV;
		double DW = (enter.part.material_f * enter.part.material_V 
		           - leave.part.material_f * leave.part.material_V) * UNITS.EV;

		if(DV == 0.0) {
			/* Same potential, directly transport to the next part.*/
			enter.velocity = leave.velocity;
			enter.weight = leave.weight;
			return true;
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
			Transport.reflect(track, leave);
			enter.weight = weight * mu;
			return false;
		} else {
			return true;
		}
	}
}
}
