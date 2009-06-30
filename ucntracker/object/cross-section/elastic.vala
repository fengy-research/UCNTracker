
[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class ElasticCrossSection : CrossSection {
		public Endf.Elastic section;
		public Endf.MFType mf {get; set;}
		public int mat {get; set;}
		public Endf.MTType mt {get; set;}
		public double T {get; set;}

		construct {
		hit += (obj, track, vertex) => {
			reload();
			message("hit on track %p, at %s", track, vertex.position.to_string());
			double E = track.get_kinetic_energy();
			double E_in_EV = E / ( 1.0 * UNITS.EV);
			section.E = E_in_EV;
			section.T = vertex.part.temperature;
			double mu;
			try {
				section.random_event(UniqueRNG.rng, out mu);
			} catch (GLib.Error e){
				critical("%s", e.message);
			}
			double phi = UniqueRNG.rng.uniform() * Math.PI * 2.0;
			double s = Math.sqrt(1.0 - mu * mu);

			Quaternion q = Quaternion.from_two_vectors(
				Vector(0, 0, 1),
				vertex.velocity.direction());
			Vector new_direction_rel_to_z = Vector(s * Math.cos(phi), 
					s * Math.sin(phi), mu);

			message("q = %s", q.to_string());
			message("mu= %lf, phi = %lf", mu, phi);
			message("velocity before hit = %s ", vertex.velocity.to_string());
			/* new velocity */
			Vector v2 = q.rotate_vector(new_direction_rel_to_z).mul(vertex.velocity.norm());
			double inner = v2.dot(vertex.velocity);
			double kcos = inner/v2.norm2();
			message("mu check = %lf", kcos);
			vertex.velocity = v2;
			message("velocity after hit = %s ", vertex.velocity.to_string());
		};

			
		}
		private void reload() {
			if(section == null)
				section = Experiment.endfs.lookup((Endf.MATType)mat, mf, mt) as Endf.Elastic;
			message("%d %d %d", mat, mf, mt);
			assert(section != null);
		}
		public override double sigma(Track track, Vertex vertex) {
			reload();
			double E = track.get_kinetic_energy();
			double E_in_EV = E / ( 1.0 * UNITS.EV);
			section.E = E_in_EV;
			section.T = vertex.part.temperature;
			double s = section.S() * UNITS.BARN;
			message(" E_in_EV = %lg Sigma = %lg", E_in_EV, s);
			return s;
			
		}
		
	}
}
