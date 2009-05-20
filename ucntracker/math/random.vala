[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class UniqueRNG {
		public static Gsl.RNG rng = new Gsl.RNG(Gsl.RNGTypes.mt19937);
	}
	public class MultiChannelRNG {
		public delegate bool ChannelFunction ();
		private struct Channel {
			public double width;
			public double bin_min;
			public double bin_max;
			public ChannelFunction function;
		}
		private Channel[] chs = null;
		private double total = 0.0;
		public MultiChannelRNG (size_t channels) {
			this.chs = new Channel[channels];
		}
		public void set_ch(int id, double width, ChannelFunction function) {
			assert(id < chs.length);
			chs[id].width = width;
			chs[id].function = function;
			update();
		}
		public void set_ch_width(int id, double width) {
			assert(id < chs.length);
			chs[id].width = width;
			update();
		}
		public double get_ch_width(int id) {
			assert(id < chs.length);
			return chs[id].width;
		}
		public void set_ch_function(int id, ChannelFunction function) {
			assert(id < chs.length);
			chs[id].function = function;
			update();
		}
		public ChannelFunction get_ch_function(int id) {
			assert(id < chs.length);
			return chs[id].function;
		}
		public void resize(size_t new_size) {
			this.chs.resize((int)new_size);
		}

		private void update() {
			total = 0.0;
			for (int i = 0; i< chs.length; i++) {
				chs[i].bin_min = total;
				total += chs[i].width;
				chs[i].bin_max = total;
			}
		}

		public bool select(Gsl.RNG rng) {
			double random = rng.uniform() * total;
			for (int i = 0; i< chs.length; i++) {
				if(chs[i].bin_min <= random && chs[i].bin_max > random) {
					assert(chs[i].function != null);
					return chs[i].function();
				}
			}
			error("The code never reaches here");
			breakpoint();
			return false;
		}
	}
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
