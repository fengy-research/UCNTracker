SUBDIRS = builder core . tests

VALASOURCES = ucntracker.vala

lib_LTLIBRARIES = libucntracker.la 

libucntracker_la_SOURCES =  \
				$(VALASOURCES:.vala=.c) \
				$(VALASOURCES:.vala=.h)

libucntracker_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) \
			-I$(top_srcdir) -I$(top_builddir) \
			-include config.h

libucntracker_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) \
			builder/libbuilder.la \
			core/libcore.la

libucntracker_la_LDFLAGS = 

BUILT_SOURCES = vala-ccode ucntracker.vapi
VALAFLAGS = --library=ucntracker --basedir=$(top_builddir)
VALAPKGS = $(PLUGIN_VAPI_FILES) --pkg gmodule-2.0
@VALA_CCODE_RULES@
ucntracker.vapi: vala-ccode
	cat core/core.vapi builder/builder.vapi >> ucntracker.vapi

