[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class UniqueRNG {
		public static Gsl.RNG rng = new Gsl.RNG(Gsl.RNGTypes.mt19937);
	}
	namespace Randist {

		public class PDFDist {
			public delegate double Distribution(double x);
			private Gsl.RanDiscrete rd;
			public double left {get; set;}
			public double right {get; set;}
			public Distribution pdf;
			public const int NBINS = 1000;
			public double[] values = new double[NBINS];
			public void init() {
				for (int i = 0; i < NBINS; i++) {
					values[i] = pdf(left + (right - left) * i / NBINS);
				}
				rd = new Gsl.RanDiscrete(values);
			}
			public double next(Gsl.RNG rng) {
				size_t i = rd.discrete(rng);
				return left + (right - left) * i / NBINS;
			}
		}
	}
}
