[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class CustomField: Field {
		/* 
		 * If evaludated, return true,
		 * otherwise return false 
		 * */
		public delegate bool FieldFunction(Track track, Vector position, Vector velocity, out Vector acceleration);
		public FieldFunction function = null;
		public override bool fieldfunc(Track track, Vector position, Vector velocity, out Vector acceleration) {
			if(function == null) return false;
			return function(track, position, velocity, out acceleration);
		}
	}
}
