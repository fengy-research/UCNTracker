
noinst_LTLIBRARIES = libcore.la
libcore_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS)
libcore_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS)  -I$(top_srcdir) -I$(top_srcdir)/ucntracker -DG_LOG_DOMAIN=\"UCNTracker\" -DINFO=

libcore_la_SOURCES =  \
	$(VALASOURCES:.vala=.c)	\
	$(VALASOURCES:.vala=.h)

VALASOURCES = \
	types.vala \
	vector.vala \
	surface.vala \
	volume.vala \
	volume-simple.vala \
	volume-ball.vala \
	volume-box.vala \
	volume-cylinder.vala \
	curve.vala \
	experiment.vala \
	intersection.vala \
	run.vala \
	vertex.vala \
	evolve.vala \
	track.vala \
	part.vala \
	core.vala 

BUILT_SOURCES = vala-ccode
VALAFLAGS= --library=core --basedir=$(top_srcdir)/ucntracker
VALAPKGS = ../physics/physics.vapi ../builder/builder.vapi --pkg gsl --pkg gmodule-2.0
@VALA_CCODE_RULES@
