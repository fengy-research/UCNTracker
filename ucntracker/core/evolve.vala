[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	internal class Evolution {

		private weak Track track;
		/*INIT_STEP_SIZE is used by the OdeivEvolve */
		public const double INIT_STEP_SIZE = 1.0;
		/* HOPS_PER_MFP is used to determinate the next
		 * dt to call move_to() */
		public const double HOPS_PER_MFP = 10.0;
		private Gsl.OdeivStep ode_step;

		private Gsl.OdeivSystem ode_system;
		private Gsl.OdeivControl ode_control;
		private Gsl.OdeivEvolve ode_evolve;

		private double step_size;

		private double free_length;

		public Evolution(Track track) {
			ode_system.function = F;
			ode_system.jacobian = J;
			ode_system.dimension = 6;
			ode_system.params = this;
			ode_step = new Gsl.OdeivStep(Gsl.OdeivStepTypes.rk8pd, 6);
			ode_control = new Gsl.OdeivControl.y(1.0e-8, 0.0);
			ode_evolve = new Gsl.OdeivEvolve(6);
			step_size = INIT_STEP_SIZE;
			this.track = track;
		}

		private static int F(double t, 
			[CCode (array_length = false)]
			double[] y, 
			[CCode (array_length = false)]
			double[] dydt, void * params) {
		    Evolution ev = (Evolution)params;
		    Vector vel = ev.track.tail.velocity;
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

		public void reintegrate_to(Vertex future, double dt) {
			double [] y = track.tail.to_array();
			double [] yerr = new double[6];
			double t0 = track.tail.timestamp;
			ode_step.reset();
			ode_step.apply(t0, dt, y, yerr, null, null, &ode_system);
			future.from_array(y);
			future.timestamp = t0 + dt;
		}
		public void integrate(Vertex future, ref double dt) {
			double [] y = track.tail.to_array();
			double t0 = track.tail.timestamp;
			double t1 = t0 + dt;

			ode_evolve.apply(ode_control, ode_step, &ode_system,
			ref t0, t1, ref step_size, y);
			dt = t0 - track.tail.timestamp;

			future.from_array(y);
			/* timestamp is also recovered from the array, which sucks*/
			future.timestamp = t0;
			//message("%lf %lf %lf %lf %lf %lf", y[0], y[1], y[2], y[3], y[4], y[5]);
		}

		public Vector cfunc(double dt) {
			Vertex future = new Vertex();
			reintegrate_to(future, dt);
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

			return future.position;
		}

		private void move_to(Vertex next, bool do_not_scatter) {
			double dl = track.estimate_distance(next);
			/*First do physical length accounting*/
			track.length += dl;
			/*Then do mean free length accounting*/
			dl /= track.tail.part.calculate_mfp(next);

			/**** 
			 * see if an interaction occurred
			 * during this motion period
			 * Formula from Wikipedia entry Mean Free Path
			 * ** */
			double dP = Math.exp( -free_length)
				  - Math.exp((-free_length - dl));
			double r = Random.uniform();

			if(!do_not_scatter && r < dP) {
				/*
				 * if scattering occurred, emit the hit signal
				 * and reset the free_length accounting.
				 * */
				track.tail.part.hit(track, next);
				free_length = 0.0;
			} else {
				/* nothing happened, accumulate the free_length
				 * accounting*/
				free_length += dl;
			}
			/* After Scattering, simply push the adjusted
			 * state to the tail*/

			var prev = track.tail;
			track.tail = next;
			track.history.push_tail(track.tail);
			if(track.history.length > Track.history_length) {
				track.history.pop_head();
			}
			/*****
			 * Always invoke the track_motion notify 
			 *
			 * NOTE:
			 * Signals are slow.
			 * GLib will skip the signal emission if
			 * no handler is registered on track_motion_notify.
			 * Productive code should only register to
			 * hit for implementing physics.
			 *
			 * We don't expect users really register to this
			 * unless it is a visualizer it is debugging.
			 * */
			track.run.track_motion_notify(track, prev);
		}
		/* return TRUE if terminated.*/
		public void evolve() {
			if(track.tail.part == null) {
				track.run.terminate_track(track);
				return;
			}
			double dt = track.tail.part.calculate_mfp(track.tail) /
			        (HOPS_PER_MFP * track.tail.velocity.norm());

			//message("mfp = %lf dt = %lf",
			//track.tail.part.calculate_mfp(track.tail.vertex), dt);
			Vertex next = new Vertex();
			integrate(next, ref dt);
			/*
			message("next: %lf %lf %lf",
			    next.vertex.position.x,
			    next.vertex.position.y,
			    next.vertex.position.z);
			*/
			next.locate_in(track.experiment);

			if(track.tail.volume == next.volume) {
				move_to(next, false);
				return;
			}

			double dt_leave;
			/* assign a value to shut up the compiler,
			 * dt_enter is used only if is_enter is true, which means
			 * out dt_enter is excuted. */
			double dt_enter = 0.0;

			bool is_leave = track.tail.volume.intersect(cfunc, 0, dt, out dt_leave);
			bool is_enter = (next.part != null)
			        && next.volume.intersect(cfunc, 0, dt, out dt_enter);

			Vertex leave = null;
			Vertex enter = null;
			//message("%s %s", is_leave.to_string(), is_enter.to_string());

			if(is_leave && is_enter) {
				leave = new Vertex();
				enter = new Vertex();
				reintegrate_to(leave, dt_leave);
				reintegrate_to(enter, dt_enter);
			}
			if(is_leave) {
				leave = new Vertex();
				reintegrate_to(leave, dt_leave);
				enter = leave.clone();
			}
			if(is_enter) {
				enter = new Vertex();
				reintegrate_to(enter, dt_enter);
				leave = enter.clone();
			}

			leave.part = track.tail.part;
			leave.volume = track.tail.volume;
			enter.part = next.part;
			enter.volume = next.volume;

			bool transported = true;
			track.tail.part.transport(track, leave, enter, &transported);

			if(transported == false) {
				move_to(leave, false);
			} else {
				move_to(leave, true);
				free_length = 0.0;
				move_to(enter, true);
			}
			return;
		}
	}
}
