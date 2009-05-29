[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public enum Sense {
		/**
		 * Sense is defined to describe the relative position relation
		 * between a point and a volume.
		 * -1 if inside
		 * 0 if on(very close) the surface
		 * +1 if outside
		 */
		IN = -1,
		ON = 0,
		OUT = 1
	}
	public abstract class Volume: Transformable, GLib.YAML.Buildable {
		private Gsl.RNG rng = new Gsl.RNG(Gsl.RNGTypes.mt19937);
		public const double thickness = 1e-6; /* Used by sense */
		public double bounding_radius { get; protected set; }

		/**
		 * generate a point in the volume or on the surface.
		 *
		 * open: if true, treat the volume as an open one,
		 *        so that the surface is not sampled.
		 */
		public virtual Vector sample(bool open) {
			double x, y, z;
			double r;
			/* workaround bug 574352 */
			Vector point = Vector(0.0, 0.0, 0.0);
			Sense s = Sense.OUT;
			do{
				Gsl.Randist.dir_3d( rng, out x, out y, out z);
				r = rng.uniform();
				r = Math.cbrt(r) * bounding_radius;
				point = Vector(x * r, y * r, z * r);
				body_to_world(point);
				s = sense(point);
			} while(s == Sense.OUT || (open && s == Sense.ON));
			return point;
		}


		/**
		 * return the sense of the point.
		 *
		 * - for inside;
		 * + for outside;
		 * 0 for on surface;
		 */
		public virtual Sense sense(Vector point) {
			if(point.distance(center) > bounding_radius + thickness) {
				/* if the point is out of the bounding ball,
				 * don't bother calling sfunc and do the rotation
				 * */
				return Sense.OUT;
			}
			double s = sfunc(point);
			//if(fabs(s) < thickness) return Sense.ON;
			if(s < 0.0) return Sense.IN;
			if(s == 0.0) return Sense.ON;
			return Sense.OUT;
		}


		/**
		 * If the volume is visible in the visualization 
		 * */
		public bool visible {get; set; default = true;}
	}
}
