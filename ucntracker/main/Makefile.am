noinst_LTLIBRARIES = libmain.la 

libmain_la_SOURCES = $(VALASOURCES:.vala=.h) $(VALASOURCES:.vala=.c)

libmain_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) \
			-I$(top_srcdir)/ucntracker -I$(top_builddir) \
			-include config.h

libmain_la_LDFLAGS = 

BUILT_SOURCES = vala-ccode 


VALASOURCES = ucntracker.vala plugin-manager.vala
VALAFLAGS = --library main --basedir=$(top_srcdir)/ucntracker
VALAPKGS = ../math/math.vapi ../physics/physics.vapi ../core/core.vapi ../builder/builder.vapi --pkg gmodule-2.0
@VALA_CCODE_RULES@


EXTRA_DIST = $(VALASOURCES) vala-ccode main.vapi
maininclude_HEADERS =  $(VALASOURCES:.vala=.h)
mainincludedir = $(includedir)/ucntracker/main
