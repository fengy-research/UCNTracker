using UCNTracker;

/**
 * Surface Transport subroutines
 * */
public class Transport {
	/*
	public static void through(Part part, Track track, 
	    Vertex leave, Vertex enter, bool* transported) {
		*transported = true;
	}
	public static void reflect(Part part, Track track,
		Vertex leave, Vertex enter, bool* transported) {
		Vector norm = track.tail.volume.grad(leave.position);
		leave.velocity = leave.velocity.reflect(norm);
		*transported = false;
	}*/
	public static void optic_reflect(Part p, Track track,
		   Vertex leave, Vertex enter, ref bool transported) {
		Vector norm = track.tail.volume.grad(leave.position);
		//message("norm = %s", norm.to_string());
		Vector reflected = leave.velocity.reflect(norm);
		//message("v_ref = %s", reflected.to_string());
		leave.velocity = reflected;
		transported = false;
	}
}
