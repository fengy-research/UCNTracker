[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class UniqueRNG {
		public static Gsl.RNG rng = new Gsl.RNG(Gsl.RNGTypes.mt19937);
	}
	public class MultiChannelRNG {
		public delegate bool ChannelFunction ();
		private class Channel {
			public double size;
			public double bin_min;
			public double bin_max;
			public ChannelFunction function;
		}
		List<Channel> channels = null;
		public void add_channel(double size, ChannelFunction function) {
			Channel channel = new Channel();
			channel.size = size;
			channel.function = function;

			channel.bin_min = total_size();
			channel.bin_max = channel.bin_min + size;
			channels.prepend(channel);
		}
		private double total_size() {
			if(channels == null) {
				return 0.0;
			}
			return channels.data.bin_max;
		}
		public bool execute(Gsl.RNG rng) {
			double random = rng.uniform() * total_size();
			foreach(unowned Channel ch in channels) {
				if(ch.bin_min <= random && ch.bin_max > random) {
					return ch.function();
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
