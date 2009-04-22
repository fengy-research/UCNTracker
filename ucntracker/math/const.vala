using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	/***
	 * Internal Units:
	 * length == cm
	 * time = second
	 * mass = KG
	 * charge = columb
	 * energy = J
	 * mdm = J/Tesla
	 *
	 */
	namespace UNITS {
		/*Length */
		public const double CM = 1.0; /*M*/
		public const double M = 1.0e2 * CM;

		/*Time */
		public const double S = 1.0;

		/*Mass */
		public const double KG = 1.0;
		public const double MEV_MASS = 1.783E-30 * KG;

		/*E & M*/
		public const double TESLA = 1.0;
		public const double COULUMB = 1.0; /* C */
		public const double GAUSS = 1e-4 * TESLA; /* T */

		/*Energy*/
		public const double J = 1.0 * KG * M * M / S / S;
		public const double EV = 1.60217653E-19 * J;

		public const double MU_BOHR = 927.400915E-26 * J / TESLA; 

		/* Planks */
		public const double H_BAR = 1.05457158E-34 * J * S;
		public const double H = H_BAR * (2.0 * PI) * J * S;
	}
}
