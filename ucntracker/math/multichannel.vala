[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class MultiChannelRNG {
		public delegate void ChannelFunction ();
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

		public int select(Gsl.RNG rng) {
			assert(total > 0.0);
			double random = rng.uniform() * total;
			for (int i = 0; i< chs.length; i++) {
				if(chs[i].bin_min <= random && chs[i].bin_max > random) {
					if(chs[i].function != null) chs[i].function();
					return i;
				}
			}
			error("The code never reaches here");
			breakpoint();
			return -1;
		}
	}
}
