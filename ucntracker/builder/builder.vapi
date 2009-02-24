[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	[CCode (cheader_filename = "builder/gtkbuilder.h")]
	public class Builder : GLib.Object {
		public uint add_from_file (string filename) throws GLib.Error;
		public uint add_from_string (string buffer, size_t length) throws GLib.Error;
		public void connect_signals (void* user_data);
		public void connect_signals_full (BuilderConnectFunc func);
		public static GLib.Quark error_quark ();
		public unowned GLib.Object get_object (string name);
		public unowned GLib.SList get_objects ();
		public unowned string get_translation_domain ();
		public virtual GLib.Type get_type_from_name (string type_name);
		[CCode (has_construct_function = false)]
		public Builder ();
		public void set_translation_domain (string domain);
		public bool value_from_string (GLib.ParamSpec pspec, string str, GLib.Value value) throws GLib.Error;
		public bool value_from_string_type (GLib.Type type, string str, GLib.Value value) throws GLib.Error;
		public string translation_domain { get; set; }
	}
	[CCode (cheader_filename = "builder/gtkbuildable.h")]
	public interface Buildable {
		public virtual void add_child (Builder builder, GLib.Object child, string? type);
		public virtual GLib.Object? construct_child (Builder builder, string name);
		public virtual void custom_finished (Builder builder, GLib.Object child, string tagname, void* data);
		public virtual void custom_tag_end (Builder builder, GLib.Object child, string tagname, void* data);
		public virtual bool custom_tag_start (Builder builder, GLib.Object child, string tagname, GLib.MarkupParser parser, void* data);
		public virtual unowned GLib.Object get_internal_child (Builder builder, string childname);
		public virtual unowned string get_name ();
		public virtual void parser_finished (Builder builder);
		public virtual void set_buildable_property (Builder builder, string name, GLib.Value value);
		public virtual void set_name (string name);
	}

	[CCode (cname="GtkBuilderConnectFunc")]
	public delegate void BuilderConnectFunc (Builder builder, GLib.Object object, string signal_name, string handler_name, GLib.Object connect_object, GLib.ConnectFlags flags);

}
