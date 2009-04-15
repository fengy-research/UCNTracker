using GLib;
using Math;


[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class PluginModule: GLib.TypeModule {
		public static delegate bool ModuleInitFunc(PluginModule module);
		private static delegate void ModuleUninitFunc(PluginModule module);
		public string filename;
		public string init_func_name;
		private Module library;
		ModuleInitFunc init;
		ModuleUninitFunc uninit;
		public PluginModule(string filename, string init_func) {
			this.filename = filename;
			this.init_func_name = init_func_name;
			library = Module.open(filename, 0);
			void * pointer;
			library.symbol(init_func_name, out pointer);
			init = (ModuleInitFunc) pointer;
		}
		public PluginModule.@static (ModuleInitFunc init_func) {
			this.filename = null;
			this.init = init_func;
		}
		public override bool load() {
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
	}

}
