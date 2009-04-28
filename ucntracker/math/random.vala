using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	namespace Randist {
		
		public class PDFDist {
			public static delegate double Distribution(double x);
			public double normalization;
			public double left {get; set;}
			public double right {get; set;}
			public Distribution pdf {get; set;}
			public const int NBINS = 1000;
			public double[] values = new double[NBINS + 2];
			public void init() {
				normalization = 0.0;
				for (int i = 0; i <= NBINS; i++) {
					values[i] = normalization;
					normalization += pdf(left + (right - left) * i / NBINS);
				}
				values[NBINS + 1] = normalization;
			}
			public double next(Gsl.RNG rng) {
				double X = rng.uniform() * normalization;
				int i = 0;
				while(values[i] < X && i <= NBINS) i++;
				return left + (right - left) * i / NBINS;
			}
		}
	}
}
