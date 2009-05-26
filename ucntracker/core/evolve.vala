[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	internal class Evolution {

		private weak Track track;
		private weak Experiment experiment {
			get { return track.experiment; }
		}
		private weak Vertex tail {
			get {return track.tail;}
			set {track.tail = value;}
		}

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

		private double [] y;
		private double [] yerr;

		public Evolution(Track track) {
			ode_system.function = F;
			ode_system.jacobian = null; /*No Jacobian */
			ode_system.dimension = track.dimensions;
			ode_system.params = this;
			ode_step = new Gsl.OdeivStep(Gsl.OdeivStepTypes.rk2, track.dimensions);
			ode_control = new Gsl.OdeivControl.scaled(1e-8, 1e-4, 1.0, 0.0, track.tolerance);
			ode_evolve = new Gsl.OdeivEvolve(track.dimensions);
			step_size = track.run.experiment.max_time_step;
			this.track = track;
			y = new double[track.dimensions];
			yerr = new double[track.dimensions];
		}

		private static int F(double t, 
			[CCode (array_length = false)]
			double[] y, 
			[CCode (array_length = false)]
			double[] dydt, void * params) {
		    Evolution ev = (Evolution)params;
			Vertex Q = ev.track.create_vertex();
			Vertex dQ = ev.track.create_vertex();
			Q.from_array(y);
			dQ.position = Q.velocity;
			Vector accel = ev.track.experiment.accelerate(ev.track, Q);
			dQ.velocity = accel;
		    dQ.to_array(dydt);

		    return Gsl.Status.SUCCESS;
		}
		/*
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
		} */

		private void integrate(Vertex future, ref double dt) {
			tail.to_array(y);
			double t0 = tail.timestamp;
			double t1 = t0 + dt;

			ode_evolve.apply(ode_control, ode_step, &ode_system,
			ref t0, t1, ref step_size, y);
			dt = t0 - tail.timestamp;

			future.from_array(y);
			/* timestamp is also recovered from the array, which sucks*/
			future.timestamp = t0;
			//message("%lf %lf %lf %lf %lf %lf", y[0], y[1], y[2], y[3], y[4], y[5]);
		}


		private void adjust_leave_enter_by_part(Vertex leave, Vertex enter) {
			double t0 = leave.timestamp;
			double t1 = enter.timestamp;

			Part part_in = leave.part;
			/* by definition leave.volume is never null. */
			assert(leave.volume != null);

			double dt;
			double tc;
			double dl = leave.position.distance(enter.position);
			Vertex future = track.create_vertex();
			int count = 0;
			while(dl > 1e-9) {
				leave.to_array(y);
				tc = 0.5 * (t0 + t1);
				dt = tc - t0;
				ode_step.reset();
				ode_step.apply(t0, dt, y, yerr, null, null, &ode_system);
				future.from_array(y);
				experiment.locate(future.position, out future.part, out future.volume);
				if(future.part != part_in) {
					t1 = tc;
					enter.from_array(y);
					enter.volume = future.volume;
					enter.part = future.part;
					enter.timestamp = t1;
				} else {
					t0 = tc;
					leave.from_array(y);
					/* leave.part == future.part == part_in */
					leave.volume = future.volume;
					leave.timestamp = t0;
				}
				dl = leave.position.distance(enter.position);
				count ++;
			}

			debug("dl = %lg count = %d", dl, count);
		}
		private bool solve_surface_intersection(Surface surface, 
				Vertex leave, 
				Vertex enter) {
			double t0 = leave.timestamp;
			double t1 = enter.timestamp;

			double dt;
			double tc;
			double s0 = surface.sfunc(leave.position);
			double s1 = surface.sfunc(enter.position);
			double dl = leave.position.distance(enter.position);
			Vertex future = track.create_vertex();
			int count = 0;
			while(dl > 1e-9) {
				leave.to_array(y);
				tc = 0.5 * (t0 + t1);
				dt = tc - t0;
				ode_step.reset();
				ode_step.apply(t0, dt, y, yerr, null, null, &ode_system);
				future.from_array(y);
				experiment.locate(future.position, 
						out future.part, 
						out future.volume);
				double sc = surface.sfunc(future.position);
				if((sc < 0.0 && s1 < 0.0)
				|| (sc > 0.0 && s1 > 0.0)) {
					t1 = tc;
					s1 = sc;
					enter.from_array(y);
					enter.volume = future.volume;
					enter.part = future.part;
					enter.timestamp = t1;
					message("reduce t1");
				} else {
					message("reduce t0");
					t0 = tc;
					s0 = sc;
					leave.from_array(y);
					leave.part = future.part;
					leave.volume = future.volume;
					leave.timestamp = t0;
				}
				dl = leave.position.distance(enter.position);
				count ++;
			}
			debug("dl = %lg count = %d", dl, count);
			if(surface.is_in_region(leave.position)) return true;
			return false;
		}
		public bool check_surfaces(Vertex leave, Vertex enter, 
				out unowned Foil f, 
				out unowned Surface s) {
			foreach(var foil in track.experiment.foils) {
			foreach(var surface in foil.surfaces) {
				double s1 = surface.sfunc(leave.position);
				double s2 = surface.sfunc(enter.position);
				if((s1 > 0.0 && s2 < 0.0)
				|| (s1 < 0.0 && s2 > 0.0)) {
					Vertex leave_dup = track.clone_vertex(leave);
					Vertex enter_dup = track.clone_vertex(enter);
					if(!solve_surface_intersection(surface, leave_dup, enter_dup)) {
						continue;
					}
					f = foil;
					s = surface;
					leave_dup.copy_to(leave);
					enter_dup.copy_to(enter);
					return true;
				}
			}
			}
			return false;
		}


		private Vector guess_surface_normal_by_surface(Vertex leave, Surface surface) {
			if(surface.sfunc(leave.position) < 0.0) {
				return surface.normal(leave.position);
			} else {
				Vector n = surface.normal(leave.position);
				n.x = - n.x;
				n.y = - n.y;
				n.z = - n.z;
				return n;
			}
		}
		/* Guess a surface normal vector based on leave and enter.
		 * The two vertices should already have been adjusted by
		 * adjust_leave_enter
		 *
		 * The direction of the normal is always pointing to the leave
		 * vertex, or backward.
		 * */
		private Vector guess_surface_normal_by_part(Vertex leave, Vertex enter) {
			double sl = leave.get_sfunc_value();
			double se = enter.get_sfunc_value();
			/* se could be nan if enter.volume == null
			 * sl could not be nan because leave.volume is always non-null
			 * compaing with anything to nan is always false, according to IEEE 754.
			 * Refer to 
			 * http://www.cygnus-software.com/papers/comparingfloats/comparingfloats.htm
			 * Search for NAN in the left-frame.
			 * */
			if(Math.fabs(sl) > Math.fabs(se)) {
				Vector n = enter.volume.normal(enter.position);
				n.x = - n.x;
				n.y = - n.y;
				n.z = - n.z;
				return n;
			} else {
				/* false, either leave is closer to the border or
				 * se is NAN. */
				return leave.volume.normal(leave.position);
			}
		}
		/**
		 * about reset_free_length:
		 *   When there is a surface transport, we don't want to emit
		 *   hit signal, rather we'd like to reset all free_length counters in flt.
		 *   
		 *   NOTE: Should talk to chen-yu to see if this is the expected behavior.
		 */
		private void move_to(Vertex next, bool reset_free_length) {
			double dl = track.estimate_distance(next);
			/*First do physical length accounting*/
			track.length += dl;

			if(!reset_free_length) {
				foreach(CrossSection section in track.tail.part.cross_sections) {
					if(section.ptype == track.get_type()) 
						track.flt.advance(section, dl);
				}
			} else {
				track.flt.reset_all();
			}
			/* After Scattering, simply push the adjusted
			 * state to the tail*/

			/* FIXME: The following passage is buggy.
			 * prev is always a reference of the tail because we didn't clone it
			 * However clone is a waste of CPU time on memory allocations.
			 * Do it or not?*/

			var prev = tail;
			tail = next;

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

		public double evolve() {
			if(tail.part == null) {
				track.terminate();
				track.run.run_motion_notify();
				return 0.0;
			}
			double dt = experiment.max_time_step;
			double dt_by_mfp = track.get_minimal_mfp() /
			        (HOPS_PER_MFP * tail.velocity.norm());
			if(dt_by_mfp < dt) dt = dt_by_mfp;

			Vertex next = track.create_vertex();
			integrate(next, ref dt);

			unowned Foil foil = null;
			unowned Surface surface = null;
			unowned Part part = null;
			unowned Volume volume = null;

			experiment.locate (next.position, out part, out volume);

			next.part = part;
			next.volume = volume;

			/* Reset the weight of enter.
			 * NOTE: this has to be removed after we addin the weight tracking!
			 * */
			next.weight = tail.weight;

			Vertex leave = track.clone_vertex(track.tail);
			/* Reuse the memory of 'next'*/
			Vertex enter = next;

			bool surface_event_occurred =
				check_surfaces (leave, enter, 
					out foil, out surface);

			if(!surface_event_occurred && tail.part == part) {
				move_to(next, false);
				return dt;
			}

			bool transported = true;
			Border.Event event = Border.Event();
			event.track = track;
			event.leave = leave;
			event.enter = enter;
			Border border = null;

			if(surface_event_occurred) {
				event.normal = surface.normal(leave.position);
				event.normal = guess_surface_normal_by_surface(leave, surface);

				border = foil.border;
			} else {
				/* part event occurred */
				adjust_leave_enter_by_part(leave, enter);
				event.normal = guess_surface_normal_by_part(leave, enter);
				border = tail.part.neighbours.lookup(enter.part);
			}

			if(border != null) {
				border.execute(ref event);
				transported = event.transported;
			}
			debug("leave %s sfunc = %lg",
				leave.to_string(),
				leave.get_sfunc_value());
			debug("enter %s sfunc = %lg", 
				enter.to_string(),
				enter.get_sfunc_value());

			/* This is a key frame, we want the visualization get it.*/
			track.run.run_motion_notify();

			if(transported == false) {
				move_to(leave, false);
				return dt;
			} else {
				move_to(leave, true);
				move_to(enter, true);
				return dt;
			}
		}
	}
}
