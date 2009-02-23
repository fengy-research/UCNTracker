[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Geometry {
	public class Intersection {
		private struct solver_params {
			public unowned Volume volume;
			public double length;
			public Vector* point_in;
			public Vector* direction;
			public double value;
		}
		private static double intersect_solver_function (double t, solver_params* params) {
			Vector point = Vector(
					params->point_in->x + params->direction->x * t * params->length,
					params->point_in->y + params->direction->y * t * params->length,
					params->point_in->z + params->direction->z * t * params->length);
			assert(params->volume != null);
			double rt = params->volume.sfunc(point);
			return rt;
		}
		public static bool solve(Volume volume, Vector point_in, Vector point_out,
			   out Vector intersection) {
			if(volume.sense(point_in) == volume.sense(point_out)) {
				return false;
			}
			double length = point_in.distance(point_out);
			Vector direction = Vector((point_out.x - point_in.x)/length,
					(point_out.y - point_in.y)/length,
					(point_out.z - point_in.z)/length);

			solver_params params = {null};
			/* workaround vala bz 572079*/
			params.volume = volume;
			params.length = length;
			params.point_in = &point_in;
			params.direction = &direction;
			params.value = 0.0;

			bool converged = false;
			int iter = 0;
			int max_iter = 100;
			Gsl.Function f = {intersect_solver_function, &params};
			Gsl.RootFsolver s = new Gsl.RootFsolver(Gsl.RootFsolverTypes.brent);
			s.set (&f, 0.0, 1.0);
			int status = Gsl.Status.CONTINUE;
			do {
				iter ++;
				s.iterate();
				status = Gsl.RootTest.residual(params.value, Volume.thickness);
				if(status == Gsl.Status.SUCCESS) {
					converged = true;
					break;
				}
			} while(status == Gsl.Status.CONTINUE && iter < max_iter);
			double t = s.root;
			intersection = Vector(
					point_in.x + direction.x * t * length,
					point_in.y + direction.y * t * length,
					point_in.z + direction.z * t * length);
					
			return converged;
		
		}
	}
}
}
