[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public class Simulation {
		public GLib.YAML.Builder builder;
		public unowned Gsl.RNG rng = UniqueRNG.rng;
		public Experiment experiment {get; private set;}
		public List<Run> runs;
		public Run current_run {get {return runs.nth_data(0);}}

		public MainContext context = null;
		public MainLoop loop = null;

		public static bool created = false;

		public bool first_time_init {get; private set; default = true;}
		private static string opt_geometry_filename = null;
		private static string opt_experiment_objname = null;
		public string geometry_filename = null;
		public string experiment_objname = null;

		private static const OptionEntry[] entries = {
			{"geometry", 'g', 0, OptionArg.FILENAME, out opt_geometry_filename, "filename"},
			{"experiment", 'r', 0, OptionArg.STRING, out opt_experiment_objname, "objname"},
			{null}
		};

		public Simulation(){}
		public Simulation.with_anchor(string experiment_objname) {
			this.experiment_objname = experiment_objname;
		}

		public virtual void init() throws GLib.Error {
			experiment = get_with_cast(experiment_objname, typeof(Experiment)) as Experiment;
			runs = null;
		}

		public void init_from_string(string geometry_string) throws GLib.Error {
			builder = new GLib.YAML.Builder("UCN");
			this.geometry_filename = null;
			builder.add_from_string(geometry_string);
			init();
			first_time_init = false;
		}
		public void init_from_file(string geometry_filename) throws GLib.Error {
			builder = new GLib.YAML.Builder("UCN");
			this.geometry_filename = geometry_filename;
			assert(created  == false);
			created = true;
			FileStream fs = FileStream.open(geometry_filename, "r");
			if(fs == null) {
				/* not a perfect error tho throw */
				throw new Error.FILE_NOT_FOUND("File %s not readable/not found".printf(geometry_filename));
			}
			builder.add_from_file(fs);
			init();
			first_time_init = false;
		}

		public Object get(string? name) throws GLib.Error {
			Object obj = builder.get_object(name);
			if(obj == null) {
				throw new Error.OBJECT_NOT_FOUND("object %s not not found".printf(name));
			}
			return obj;
		}

		private Object get_with_cast(string? name, Type type) throws GLib.Error {
			Object obj = get(name);
			if(!obj.get_type().is_a(type)) {
				throw new Error.OBJECT_NOT_FOUND("object %s(%s) not a %s.".printf(name, obj.get_type().name(), type.name()));
			}
			return obj;
		}

		public Part get_part(string name) throws GLib.Error {
			return get_with_cast(name, typeof(Part)) as Part;
		}

		public Volume get_volume(string name) throws GLib.Error {
			return get_with_cast(name, typeof(Volume)) as Volume;
		}

		public CrossSection get_cross_section(string name) throws GLib.Error {
			return get_with_cast(name, typeof(CrossSection)) as CrossSection;
		}

		/**
		 * Start a simulation run.
		 *
		 * auto_attach: if auto_attach == true, the run is attached to the main context,
		 *       thus the simulation immediately starts.
		 *       if auto_attach == false, the run is not attached to the main context,
		 *       thus the simulation does not start. Unless you have a GUI or something
		 *       to attach the run later always pass-in attach = true.
		 *
		 */
		public virtual void run(bool auto_attach = true, bool auto_quit = true) {
			loop = new MainLoop(this.context, false);
			if(auto_attach) {
				Run run = add_run();
				attach_run(run);
			}
			if(auto_quit)
				finish += this.quit;
			loop.run();
			if(auto_quit)
				finish -= this.quit;
		}

		public virtual void quit() {
			loop.quit();
		}
		public void attach_run(Run run) {
			/*The run detaches itself by returning false in Run.run1,
			 * when it finishes.*/
			run.attach(this.context);
		}

		public signal void prepare(Run run);
		public signal void finish(Run run);

		public Run add_run() {
			Run run = new Run.with_simulation (this);
			runs.prepend(run);
			run.finish += this.emit_finish;
			prepare(run);
			return run;
		}
		private void emit_finish(Run run) {
			finish(run);
		}
	}
	}
}
