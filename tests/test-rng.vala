using GLib;
using UCNTracker;
public int main(string[] args) {
	UCNTracker.init(ref args);
	Gsl.RNG rng = new Gsl.RNG(Gsl.RNGTypes.mt19937);

	var pd = new UCNTracker.Randist.PDFDist();
	pd.left = - 3.14/2.0;
	pd.right = 3.14/2.0;
	pd.pdf = (x) => {return Math.pow(Math.cos(x), 2.8);};
	pd.init();
	for(int i = 0; i< 100000; i++) {
		stdout.printf("%lg\n", pd.next(rng));
	}
	return 0;
}
