VALASOURCES = random.vala \
			ptype.vala \
			transport.vala \
			physics.vala

noinst_LTLIBRARIES = libphysics.la

libphysics_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS)
libphysics_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS)  -I$(top_srcdir) -I$(top_srcdir)/ucntracker -DG_LOG_DOMAIN=\"UCNTracker\"


libphysics_la_SOURCES =  \
	$(VALASOURCES:.vala=.c)	\
	$(VALASOURCES:.vala=.h)

VALAFLAGS= --library=physics --basedir=$(top_srcdir)/ucntracker
VALAPKGS = --pkg gsl ../math/math.vapi
BUILT_SOURCES = vala-ccode
@VALA_CCODE_RULES@

EXTRA_DIST = $(VALASOURCES) vala-ccode physics.vapi
physicsinclude_HEADERS =  $(VALASOURCES:.vala=.h)
physicsincludedir = $(includedir)/ucntracker/physics
