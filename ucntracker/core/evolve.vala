using UCNTracker.Geometry;
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
namespace Device {
	public class Evolution {
		private weak Track track;
		public const double TIME_STEP_SIZE = 1.0;
		private Gsl.OdeivStep ode_step;

		private Gsl.OdeivSystem ode_system;
		private Gsl.OdeivControl ode_control;
		private Gsl.OdeivEvolve ode_evolve;

		public Evolution(Track track) {
			ode_system.function = F;
			ode_system.jacobian = J;
			ode_system.dimension = 6;
			ode_system.params = this;
			ode_step = new Gsl.OdeivStep(Gsl.OdeivStepTypes.rk8pd, 6);
			ode_control = new Gsl.OdeivControl.y(1.0e-8, 0.0);
			ode_evolve = new Gsl.OdeivEvolve(6);
			this.track = track;
		}

		private static int F(double t, 
			[CCode (array_length = false)]
			double[] y, 
			[CCode (array_length = false)]
			double[] dydt, void * params) {
		    Evolution ev = (Evolution)params;
		    Vector vel = ev.track.tail.vertex.velocity;
		    dydt[0] = vel.x;
		    dydt[1] = vel.y;
		    dydt[2] = vel.z;
		    dydt[3] = 0.0;
		    dydt[4] = 0.0;
		    dydt[5] = 0.0;

		    return Gsl.Status.SUCCESS;
		}
		private static int J(double t, 
			[CCode (array_length = false)]
			double[] y, 
			[CCode (array_length = false)]
			double[] dfdy, 
			[CCode (array_length = false)]
			double[] dfdt, void * params) {
		    Evolution ev = (Evolution)params;
			for(int i = 0; i< 6; i++) 
			for(int j = 0; j< 6; j++) {
				dfdy[i*6 + j] = 0.0;
			}
		    dfdt[0] = 0.0;
		    dfdt[1] = 0.0;
		    dfdt[2] = 0.0;
		    dfdt[3] = 0.0;
		    dfdt[4] = 0.0;
		    dfdt[5] = 0.0;
		    return Gsl.Status.SUCCESS;
		}
		public void integrate(ref State future, double dt) {
			future.vertex = track.tail.vertex.clone();
			Vector vel = track.tail.vertex.velocity;
			future.vertex.position.x += vel.x * dt;
			future.vertex.position.y += vel.y * dt;
			future.vertex.position.z += vel.z * dt;
			future.vertex.velocity = track.tail.vertex.velocity;
			future.timestamp = track.tail.timestamp + dt;
		}
		public void integrate_adaptive(ref State future, out double dt) {
			dt = TIME_STEP_SIZE;
			integrate(ref future, dt);
		}
		public Vector cfunc(double dt) {
			State future = State();
			integrate(ref future, dt);
			/*
			message("dt = %lf tail.position = %lf %lf %lf vertex.position = %lf %lf %lf",
					dt,	
					tail.vertex.position.x,
					tail.vertex.position.y,
					tail.vertex.position.z,
					future.vertex.position.x,
					future.vertex.position.y,
					future.vertex.position.z);
					*/

			return future.vertex.position;
		}

		/* return TRUE if terminated.*/
		public bool evolve() {
			if(track.tail.part == null) {
				return true;
			}
			double dt;
			State next = State();
			integrate_adaptive(ref next, out dt);
			/*
			message("next: %lf %lf %lf",
			    next.vertex.position.x,
			    next.vertex.position.y,
			    next.vertex.position.z);
			*/
			    next.locate_in(track.experiment);

			if(track.tail.volume == next.volume) {
				track.tail.part.hit(track, next);
				track.tail = next;
				return false;
			}

			double dt_leave;
			/* assign a value to shut up the compiler,
			 * dt_enter is used only if is_enter is true, which means
			 * out dt_enter is excuted. */
			double dt_enter = 0.0;

			bool is_leave = track.tail.volume.intersect(cfunc, 0, dt, out dt_leave);
			bool is_enter = (next.part != null)
			        && next.volume.intersect(cfunc, 0, dt, out dt_enter);

			State leave = State();
			State enter = State();
			//message("%s %s", is_leave.to_string(), is_enter.to_string());

			if(is_leave && is_enter) {
				integrate(ref leave, dt_leave);
				integrate(ref enter, dt_enter);
			}
			if(is_leave) {
				integrate(ref leave, dt_leave);
				enter = State.clone(leave);
			}
			if(is_enter) {
				integrate(ref enter, dt_enter);
				leave = State.clone(enter);
			}

			leave.part = track.tail.part;
			leave.volume = track.tail.volume;
			enter.part = next.part;
			enter.volume = next.volume;

			track.tail.part.hit(track, leave);
			track.tail.vertex = leave.vertex;
			track.tail.timestamp = leave.timestamp;

			bool transported = true;
			track.tail.part.transport(track, leave, enter, &transported);

		//	message("%s", transported.to_string());
			if(transported == false) {
				track.tail.part.hit(track, leave);
			} else {
				if(next.part != null)
					next.part.hit(track, enter);
				/* else we are moving out from the geometry.
				 * in the next evolve the track would be terminated.
				 * */
				track.tail.part = next.part;
				track.tail.volume = next.volume;
				track.tail.vertex = enter.vertex;
				track.tail.timestamp = enter.timestamp;
			}
			return false;
		}
	}
}
}
