using Gsl;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
public class Random {
	public static void preload() {
		rng = new RNG(RNGTypes.mt19937);
	}
	private static Gsl.RNG rng;
	public static double uniform() {
		return rng.uniform();
	}
	public static void dir_3d(out double x, out double y, out double z) {
		Randist.dir_3d(rng, out x, out y, out z);
	}
	
}
}
