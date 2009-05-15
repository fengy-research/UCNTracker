using GLib;
using Vala.Runtime;
using UCNTracker;
public class TestChannels {
	public int ch1_count;
	public int ch2_count;
	public int ch3_count;
	public void channel1() {
		ch1_count++;
	}
	public void channel2() {
		ch2_count++;
	}
	public void channel3() {
		ch3_count++;
	}
	public void reset() {
		ch1_count = ch2_count = ch3_count = 0;
	}
}
public int main(string[] args) {
	UCNTracker.init(ref args);
	Gsl.RNG rng = new Gsl.RNG(Gsl.RNGTypes.mt19937);

	var mcrng = new MultiChannelRNG();
	var chs = new TestChannels();
	mcrng.add_channel(0.5, chs.channel1);
	mcrng.add_channel(0.5, chs.channel2);
	mcrng.add_channel(0.5, chs.channel3);
	for(int j = 0; j< 10; j++) {
		chs.reset();
		for(int i = 0; i < 100000; i++) {
			mcrng.execute(rng);
		}
		stdout.printf("%d  =aprox= %d = aprox= %d\n", chs.ch1_count, chs.ch2_count, chs.ch3_count);
	}
	return 0;
}
