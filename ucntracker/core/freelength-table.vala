[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	internal class FreeLengthTable {
		private class FreeLengthEntry {
			public double free_length;
		}
		private unowned Track track;
		private HashTable<unowned CrossSection, FreeLengthEntry> hash =
		new HashTable<unowned CrossSection, FreeLengthEntry>(direct_hash, direct_equal);

		public FreeLengthTable(Track track) {
			this.track = track;
		}
		/**
		 * Advance the particle's length by physical_advanced_length. The MFP
		 * factor is divided IN this method, therefore the passed in length
		 * should be a physical length.
		 *
		 * After a reaction, the entire free length table is reset to zero.
		 *
		 * returns true if there is a reaction (hit event);
		 * false if there is no reaction.
		 */
		public bool advance (CrossSection section, double physical_advanced_length) {
			FreeLengthEntry entry = hash.lookup(section);
			if(entry == null) {
				entry = new FreeLengthEntry();
				entry.free_length = 0.0;
				hash.insert(section, entry);
			}
			double free_length = entry.free_length;
			double mfp = 1.0 / ((section.density / (UNITS.CM3) * section.sigma(track, track.tail)));
			double dl =  physical_advanced_length / mfp;
			double dP = 1.0 - Math.exp((- dl));
			double r = UniqueRNG.rng.uniform();
			bool reacted = false;
			if(r < dP) {
				section.hit(track, track.tail);
				reset_all();
				reacted = true;
				track.run.run_motion_notify();
			} else {
				free_length += dl;
				entry.free_length = free_length;
			}
			return reacted;
		}
		public void reset_all() {
			/*FIXME: foreach entry set free_length to zero. remove_all will free 
			 * the entries' memory, which will eventually be reallocated.
			 * That's a waste */
			hash.remove_all();
		}
	}
}
