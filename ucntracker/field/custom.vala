[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class CustomField: Field {
		/* 
		 * If evaludated, return true,
		 * otherwise return false 
		 * */
		public delegate bool FieldFunction(Track track, Vertex Q, Vertex dQ);
		public FieldFunction function = null;
		public override bool fieldfunc(Track track, Vertex Q, Vertex dQ) {
			if(function == null) return false;
			return function(track, Q, dQ);
		}
	}
}
