using UCNTracker;

namespace Endf {
	public enum LTHRType {
		COHERENT = 1,
		INCOHERENT = 2,
	}
	/**
	 * An object for a Section in the ENDF file.
	 *
	 * The most useful interfaces are `load' and
	 * `S'.
	 *
	 * `load' is to load the event.content into this section 
	 * object.
	 *
	 * S(E, T) returns an interpolated S 
	 * corresponding to the reaction.
	 */
	public class MF7MT2 {
		private struct Page {
			public double [] S;
			public double [] s;
			public INTType LI;
		}
		double [] T;
		Page [] pages;
		double [] E;
		Interpolation INT;
		public MTType MT;
		public MFType MF;
		public MATType MAT;

		public double ZA; /* first number in the first row */
		double AWR; /* second number in the first row */
		public int NP; /* number of data points*/
		int NR; /* number of interpolation ranges */

		public LTHRType LTHR;
		/* For LTHR = COHERENT */
		public int LT; /* Temperature points (number of pages) - 1*/
		/* For LTHR = INCOHERENT */
		public double SB; /* Characteristic bound cross section (barns) */

		/* Debye-Waller integral divided by the atomic mass eV-1,
		 * as a function of T(K)*/
		public double[] W;

		private MultiChannelRNG mcrng;

		private int find_T(double T) {
			for(int i = 1; i < this.T.length; i++) {
				if(this.T[i] > T && this.T[i - 1] <= T)
					return i - 1;
			}
			return -1;
		}

		/** 
		 * The total cross section for given E.
		 * */
		public double S(double E, double T) {
			switch(LTHR) {
				case LTHRType.COHERENT:
					int iT = find_T(T);
					if(iT == -1) return double.NAN;
					double S0 = INT.eval(E, this.E, pages[iT].S);
					double S1 = INT.eval(E, this.E, pages[iT + 1].S);

					double S_E_T = Interpolation.eval_static(
						pages[iT + 1].LI,
						T, this.T[iT], this.T[iT +1], S0, S1);
					return S_E_T / E;
				case LTHRType.INCOHERENT:
					double W_T = INT.eval(T, this.T, W);
					double EW = E * W_T;
					return SB * 0.5 * ( 1 - Math.exp(-4.0 * EW)) / (2.0 * EW);
			}
			return double.NAN;
		}
		/**
		 * Returns a random angle according to the
		 * angular dependency of the cross section
		 * */
		public double angular(Gsl.RNG rng, double E, double T) {
			if(!angular_prepare(E, T)) return double.NAN;
			return angular_next(rng, E, T);
		}

		/**
		 * After angular_prepare is called return a theta
		 * angular according to the angular distributation.
		 *
		 * If LTHR == INCOHERENT, return a uniform angle for theta,
		 * because the spherical coordinates has a sin(theta) weight,
		 * the uniform angle is transformed by acos. Refer to
		 * mathworld.wolfram.com/SpherePointPicking.html
		 *
		 * If LTHR == COHERENT, returns the angle by acos(1 - 2Ei/E),
		 * where Ei is the energy of a randomly choosen bragg edge.
		 *
		 * */
		public double angular_next(Gsl.RNG rng, double E, double T) {
			if(LTHR == LTHRType.INCOHERENT) {
				return Math.acos(2.0 * rng.uniform() - 1.0);
			}
			int ch = mcrng.select(rng);
			return Math.acos(1.0 - 2.0 * this.E[ch] / E);
		}

		public bool angular_prepare(double E, double T) {
			if(LTHR == LTHRType.INCOHERENT) {
				return true;
			}
			int iT = find_T(T);
			if(iT == -1) return false;
			int i;
			for(i = 0; i < this.E.length && this.E[i] < E; i++ ){
				double s0 = pages[iT].s[i];
				double s1 = pages[iT + 1].s[i];

				double s = Interpolation.eval_static(
						pages[iT + 1].LI,
						T, this.T[iT], this.T[iT +1], s0, s1);

				mcrng.set_ch_width(i, s);
			}
			mcrng.set_eff_channels(i);
			
			return true;
		}

		public void load(SectionEvent event) {
			assert(event.MF == MFType.THERMAL_SCATTERING);
			assert(event.MT == MTType.ELASTIC);
			MT = event.MT;
			MAT = event.MAT;
			MF = event.MF;
			weak string p = event.content;
			/* first line */
			ZA = read_number(p, out p);
			AWR = read_number(p, out p);
			LTHR = (LTHRType) read_number(p, out p);
			skip_to_next_line(p, out p);

			switch(LTHR) {
				case LTHRType.COHERENT:
					load_coherent(p, out p);
				break;
				case LTHRType.INCOHERENT:
					load_incoherent(p, out p);
				break;
			}	
		}
		private void load_coherent(string p, out weak string outptr) {
			load_first_page(p, out p);
			
			for(int i = 1; i < LT + 1; i++) {
				load_other_page(i, p, out p);
			}
			outptr = p;
		}
		private void load_incoherent(string p, out weak string outptr) {
			SB = read_number(p, out p);
			assert(0.0 == read_number(p, out p));
			assert(0.0 == read_number(p, out p));
			assert(0.0 == read_number(p, out p));

			NR = (int) read_number(p, out p);
			NP = (int) read_number(p, out p);

			INT = new Interpolation(NR);
			INT.load(p, out p);


			W = new double[NP];
			T = new double[NP];

			for(int i = 0; i < NP; i++) {
				T[i] = read_number(p, out p);
				W[i] = read_number(p, out p);
			}

			skip_to_next_line(p, out p);

			outptr = p;
		}

		private void load_first_page(string p, out weak string outptr) {
			/* second line */
			double T0 = read_number(p, out p);
			//assert (0.0 == read_number(p, out p));
			assert (0.0 == read_number(p, out p));
			LT = (int) read_number(p, out p);
			assert (0.0 ==read_number(p, out p));
			NR = (int) read_number(p, out p);
			NP = (int) read_number(p, out p);

			pages = new Page[LT + 1];
			T = new double[LT+1];
			T[0] = T0;
			pages[0].S = new double[NP];
			pages[0].s = new double[NP];

			INT = new Interpolation(NR);
			mcrng = new MultiChannelRNG(NP - 1);

			INT.load(p, out p);

			E = new double[NP];
			double prevS = 0.0;
			for(int i = 0; i < NP; i ++) {
				E[i] = read_number(p, out p);
				double S = read_number(p, out p);
				pages[0].S[i] = S;
				if(i > 0)
					pages[0].s[i - 1] = S - prevS;
				prevS = S;
			}
			skip_to_next_line(p, out p);
			outptr = p;
		}
		private void load_other_page(int page_number, 
			string p, out weak string outptr) {
			double T1 = read_number(p, out p);
			assert(0.0 == read_number(p, out p));
			INTType LI =  (INTType) read_number(p, out p);
			assert(0.0 == read_number(p, out p));
			int NP = (int) read_number(p, out p);
			skip_to_next_line(p, out p);

			pages[page_number].S = new double[NP];
			pages[page_number].s = new double[NP];

			T[page_number] = T1;
			pages[page_number].LI = LI;
			assert(NP == this.NP);
			double prevS = 0.0;
			for(int i = 0; i< NP; i ++) {
				double S = read_number(p, out p);
				pages[page_number].S[i] = S;
				if(i > 0)
					pages[page_number].s[i - 1] = S - prevS;
				prevS = S;
			}
			skip_to_next_line(p, out p);
			outptr = p;
		}
	}
}
