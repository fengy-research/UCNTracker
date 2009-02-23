
using GLib;
using Math;

[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	PluginModuleManager manager = null;
	public bool init([CCode (array_length_pos = 0.9)] ref unowned string[] args) {
		manager = new PluginModuleManager();
		manager.query_static("ucn_geometry_init");
		manager.query_static("ucn_device_init");
		return true;
	}
}
