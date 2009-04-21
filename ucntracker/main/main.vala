
using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public PluginModuleManager manager = null;
	public bool init([CCode (array_length_pos = 0.9)] ref unowned string[] args) {
		Random.preload();
		manager = new PluginModuleManager();
		return true;
	}
	public void main() {

	}
}
