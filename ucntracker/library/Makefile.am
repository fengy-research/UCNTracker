lib_LTLIBRARIES = libinit.la 

libinit_la_SOURCES = $(VALASOURCES:.vala=.h) $(VALASOURCES:.vala=.c)

libinit_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) \
			-I$(top_srcdir)/ucntracker -I$(top_builddir) \
			-include config.h

libinit_la_LDFLAGS = 

BUILT_SOURCES = vala-ccode 


VALASOURCES = ucntracker.vala plugin-manager.vala
VALAFLAGS = --library init --basedir=$(top_srcdir)/ucntracker
VALAPKGS = ../physics/physics.vapi ../core/core.vapi ../builder/builder.vapi --pkg gmodule-2.0
@VALA_CCODE_RULES@


