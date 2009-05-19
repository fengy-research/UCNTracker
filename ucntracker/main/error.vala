[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	public errordomain Error {
		/* Demangler Could not find a symbol */
		SYMBOL_NOT_FOUND,

		/* Builder could not resolve a type*/
		TYPE_NOT_FOUND,
		NOT_A_BUILDABLE,
		PROPERTY_NOT_FOUND,
		OBJECT_NOT_FOUND,
		UNKNOWN_PROPERTY_TYPE,
		CUSTOM_NODE_ERROR,

		UNEXPECTED_NODE,
		NOT_IMPLEMENTED
	}
}
