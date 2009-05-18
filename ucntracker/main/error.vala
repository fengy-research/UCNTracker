[CCode (cprefix = "UCN", lower_case_cprefix = "ucn_")]
namespace UCNTracker {
	errordomain Error {
		/* Demangler Could not find a symbol */
		SYMBOL_NOT_FOUND,

		/* Build could not resolve a type*/
		TYPE_NOT_FOUND,
		NOT_A_BUILDABLE
	}
}
