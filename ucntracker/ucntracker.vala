using GLib;
using Math;


[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class PluginModule: GLib.TypeModule {
		private static delegate void ModuleInitFunc(PluginModule module);
		private static delegate void ModuleUninitFunc(PluginModule module);
		public string filename;
		public string init_func;
		private Module library;
		ModuleInitFunc init;
		ModuleUninitFunc uninit;
		public PluginModule(string filename, string init_func) {
			this.filename = filename;
			this.init_func = init_func;
		}
		public PluginModule.@static (string init_func) {
			this.filename = null;
			this.init_func = init_func;
		}
		public override bool load() {
			library = Module.open(filename, 0);
			void * pointer;
			library.symbol(init_func, out pointer);
			init = (ModuleInitFunc) pointer;
			if(init != null) {
				init(this);
				return true;
			} else {
				return false;
			}
		}
		public override void unload() {
			if(uninit != null) uninit(this);
			library = null;
			init = null;
			uninit = null;
		}
	}
	public class PluginModuleManager {
		List<PluginModule> modules;
		public void query(string filename) {
			PluginModule module = new PluginModule(filename, 
							"ucn_plugin_module_init");
			modules.prepend(module);
			module.use();
		}
		public void query_static(string init_func) {
			PluginModule module = new PluginModule.@static(init_func);
			modules.prepend(module);
			module.use();
		}
	}
	PluginModuleManager manager = null;
	public bool init([CCode (array_length_pos = 0.9)] ref unowned string[] args) {
		manager = new PluginModuleManager();
		manager.query_static("ucn_geometry_init");
		manager.query_static("ucn_device_init");
		return true;
	}

}
