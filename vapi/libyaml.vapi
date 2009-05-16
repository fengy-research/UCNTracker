/* ********
 *
 * This work is inspired by the work in GORE project by
 *  2008 Dmitriy Kuteynikov & Denis Tereshkin.
 ***/

[CCode (cprefix="YAML", cheader_filename="yaml.h", lower_case_cprefix="yaml_")]
namespace YAML {
	
	[CCode (cname = "yaml_event_type_t", cprefix="YAML_", has_type_id = false)]
	public enum EventType
	{
		/** An empty event. */
		NO_EVENT,

		/** A STREAM-START event. */
		STREAM_START_EVENT,
		/** A STREAM-END event. */
		STREAM_END_EVENT,

		/** A DOCUMENT-START event. */
		DOCUMENT_START_EVENT,
		/** A DOCUMENT-END event. */
		DOCUMENT_END_EVENT,

		/** An ALIAS event. */
		ALIAS_EVENT,
		/** A SCALAR event. */
		SCALAR_EVENT,

		/** A SEQUENCE-START event. */
		SEQUENCE_START_EVENT,
		/** A SEQUENCE-END event. */
		SEQUENCE_END_EVENT,

		/** A MAPPING-START event. */
		MAPPING_START_EVENT,
		/** A MAPPING-END event. */
		MAPPING_END_EVENT
	}
    /** The scalar parameters (for @c YAML_SCALAR_EVENT). */
    public struct EventScalar {
        /** The anchor. */
        public unowned string anchor;
        /** The tag. */
        public unowned string tag;
        /** The scalar value. */
        public unowned string value;
        /** The length of the scalar value. */
        public size_t length;
        /** Is the tag optional for the plain style? */
        public int plain_implicit;
        /** Is the tag optional for any non-plain style? */
        public int quoted_implicit;
    };
	public struct EventData {
		public YAML.EventScalar scalar;
	}
	[CCode (cname="yaml_event_t", lower_case_cprefix="yaml_event_")]
	public struct Event {
    	public EventType type;
		public YAML.EventData data;
	}
	[CCode (cname="yaml_parser_t", lower_case_cprefix="yaml_parser_")]
	public struct Parser {
			
		public static int parse(ref YAML.Event event);
	}
	
}
