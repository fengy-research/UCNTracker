SUBDIRS = builder core . tests

lib_LTLIBRARIES = libucntracker.la 

libucntracker_la_SOURCES = $(VALASOURCES:.vala=.h) $(VALASOURCES:.vala=.c)

libucntracker_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) \
			-I$(top_srcdir) -I$(top_builddir) \
			-include config.h

libucntracker_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) \
			builder/libbuilder.la \
			core/libcore.la

libucntracker_la_LDFLAGS = 

BUILT_SOURCES = vala-ccode ucntracker.vapi

VALASOURCES = ucntracker.vala plugin-manager.vala
VALAFLAGS = --library ucntracker-temp --basedir=$(top_srcdir)
VALAPKGS = core/core.vapi builder/builder.vapi --pkg gmodule-2.0
@VALA_CCODE_RULES@
ucntracker.vapi: core/core.vapi builder/builder.vapi ucntracker-temp.vapi vala-ccode
	cat $^ > $@

