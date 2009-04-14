[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	internal class Intersector {
		private struct solver_params {
			public unowned Volume volume;
			public CurveFunc curve;
			public double value;
			public double sfunc_value;
		}

		private static double intersect_solver_function (
		        double s, solver_params* params) {
			Vector point = params->curve(s);
			assert(params->volume != null);
			double rt = params->volume.sfunc(point) - params->sfunc_value;
			params->value = rt;
			//message("solver_function(%lf) returns %lf", s, rt);
			return rt;
		}

		public const double PRECISION = 1.0e-10;

		public static bool solve(Volume volume, CurveFunc curve,
		        int direction,
		        double s_min, double s_max, out double s) {
// Really don't need to extend the ranges if the surfaces have no thickness
//			s_min -= PRECISION;
//			s_max += PRECISION;
			Vector point_in = curve(s_min);
			Vector point_out = curve(s_max);
			double sfunc_in = volume.sfunc(point_in);
			double sfunc_out = volume.sfunc(point_out);
			double sfunc_value = direction * PRECISION;

			if((sfunc_in > 0.0 && sfunc_out > 0.0)
			|| (sfunc_in < 0.0 && sfunc_out < 0.0)) {
				message("no intersection %lg %lg", sfunc_in, sfunc_out);
				return false;
			}

			/* Make sure sfunc_value has a solution */
			while((sfunc_in > sfunc_value && sfunc_out > sfunc_value)
			|| (sfunc_in < sfunc_value && sfunc_out < sfunc_value)) {
				sfunc_value /= 2.0;
			}

			solver_params params = {null};
			/* fill in the initializer after declearations,
			 * workaround vala bz 572079*/
			params.volume = volume;
			params.curve = curve;
			params.sfunc_value = sfunc_value;
			bool converged = false;

			int iter = 0;
			int max_iter = 1000;
			Gsl.Function f = {intersect_solver_function, &params};
			Gsl.RootFsolver solver =
			    new Gsl.RootFsolver(Gsl.RootFsolverTypes.brent);

			solver.set (&f, s_min, s_max);
			int status = Gsl.Status.CONTINUE;
			do {
				iter ++;
				solver.iterate();
				status = Gsl.RootTest.residual(params.value, PRECISION);
				if(status == Gsl.Status.SUCCESS) {
					converged = true;
					break;
				}
			} while(status == Gsl.Status.CONTINUE && iter < max_iter);

			s = solver.root;
			if(iter == max_iter) {
				warning("solver exceeds max num of interations. "
				    + "assuming no solution.");
				warning("residule = %lg, params.value %lg", volume.sfunc(curve(solver.root)), params.value);
			}
			/*
			switch(direction) {
				case 1:
				if(sfunc_out > 0.0 && sfunc_out <= sfunc_value) {
					s = s_max;
					return true;
				}
				if(sfunc_in > 0.0 && sfunc_in <= sfunc_value) {
					s = s_min;
					return true;
				}
				break;
				case -1:
				if(sfunc_out < 0.0 && sfunc_out >= sfunc_value) {
					s = s_max;
					return true;
				}
				if(sfunc_in < 0.0 && sfunc_in >= sfunc_value) {
					s = s_min;
					return true;
				}
				break;
			}*/


			return converged;
		}
	}
}
