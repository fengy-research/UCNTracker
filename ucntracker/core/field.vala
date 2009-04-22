using GLib;
using Math;
using Vala.Runtime;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public abstract class Field: VolumeGroup {
		public abstract void fieldfunc(Track track, Vertex Q, Vertex dQ);
	}
}
