using UCNTracker;
public class TestChannels {
	public int ch1_count;
	public int ch2_count;
	public int ch3_count;
	public bool channel1() {
		ch1_count++;
		return false;
	}
	public bool channel2() {
		ch2_count++;
		return false;
	}
	public bool channel3() {
		ch3_count++;
		return false;
	}
	public void reset() {
		ch1_count = ch2_count = ch3_count = 0;
	}
}
public int main(string[] args) {
	UCNTracker.init(ref args);
	Gsl.RNG rng = new Gsl.RNG(Gsl.RNGTypes.mt19937);

	var mcrng = new MultiChannelRNG(3);
	var chs = new TestChannels();
	mcrng.set_ch(0, 0.5, chs.channel1);
	mcrng.set_ch(1, 0.5, chs.channel2);
	mcrng.set_ch(2, 0.5, chs.channel3);
	for(int j = 0; j< 10000; j++) {
		chs.reset();
		for(int i = 0; i < 100000; i++) {
			mcrng.select(rng);
		}
		stdout.printf("%d  =aprox= %d = aprox= %d\n", chs.ch1_count, chs.ch2_count, chs.ch3_count);
	}
	return 0;
}
