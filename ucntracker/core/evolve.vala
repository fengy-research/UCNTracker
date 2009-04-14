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
		private double dt;

		private bool just_transported = false;
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
			dt = INIT_STEP_SIZE;
			this.track = track;
		}

		private static int F(double t, 
			[CCode (array_length = false)]
			double[] y, 
			[CCode (array_length = false)]
			double[] dydt, void * params) {
		    Evolution ev = (Evolution)params;
			Vertex v = new Vertex();
			Vertex pspace_vel = new Vertex();
			v.from_array(y);
			ev.track.experiment.calculate_pspace_velocity(v, pspace_vel);

		    pspace_vel.to_array(dydt);

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
			double [] y = new double[6];
			double [] yerr = new double[6];
			track.tail.to_array(y);
			double t0 = track.tail.timestamp;
			ode_step.reset();
			ode_step.apply(t0, dt, y, yerr, null, null, &ode_system);
			future.from_array(y);
			future.timestamp = t0 + dt;
		}
		public void integrate(Vertex future, ref double dt) {
			double [] y = new double [6];
			track.tail.to_array(y);
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
			message("dt = %lf vertex.position = %lf %lf %lf",
					dt,	
					future.position.x,
					future.position.y,
					future.position.z);
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

		public void evolve() {
			if(track.tail.part == null) {
				track.run.terminate_track(track);
				return;
			}
			double dt_by_mfp = track.tail.part.calculate_mfp(track.tail) /
			        (HOPS_PER_MFP * track.tail.velocity.norm());
			if(dt_by_mfp < dt) dt = dt_by_mfp;

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

			if(track.tail.part == next.part) {
				just_transported = false;
				move_to(next, false);
				return;
			}

			double dt_leave = 0.0;
			/* assign a value to shut up the compiler,
			 * dt_enter is used only if is_enter is true, which means
			 * out dt_enter is excuted. */
			double dt_enter = 0.0;

			double leave_in = 0.0;
			double leave_out = dt;
			double enter_in = 0.0;
			double enter_out = dt;
			if(just_transported) {
				 /*FIXME: to avoid the last position of the particle
				  * This is a dirty hack by slightly move forward the boundary
				  * of the solution so that the last transportation point is 
				  * skipped.
				  * May fail if two points are too close
				  * or the sfunc is to steep.
				  * */
				 leave_in = dt/1000.0;
				 //leave_in= 0.0;
			} else {
				 leave_in= 0.0;
			 }

			bool is_leave = false;
			bool is_enter = false;
			while(!is_leave && !is_enter) {
				/* If failed to determine the transport location, 
				 *
				 */

				is_leave = track.tail.volume.intersect(cfunc, 0, leave_in, leave_out, out dt_leave);
				if(next.part != null) {
			    	is_enter = next.volume.intersect(cfunc, 0, enter_in, enter_out, out dt_enter);
				}
				leave_in += (leave_out - leave_in)/100;
			}
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
			message("leave sfunc = %lg", leave.volume.sfunc(leave.position));
			/* Make sure the particle is inside the volume. */
			// maybe don't need this assert(leave.volume.sfunc(leave.position) < 0.0);

			enter.part = next.part;
			enter.volume = next.volume;

			bool transported = true;
			track.tail.part.transport(track, leave, enter, &transported);
			just_transported = true;
			message("transport event leave = %s vel = %s enter = %s next = %s", 
			leave.position.to_string(),
			leave.velocity.to_string(),
			enter.position.to_string(),
			next.position.to_string());
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
