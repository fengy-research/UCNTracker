
noinst_LTLIBRARIES = libcore.la
libcore_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS)
libcore_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS)  -I$(top_srcdir) -I$(top_srcdir)/ucntracker -DG_LOG_DOMAIN=\"UCNTracker\" -DINFO=

libcore_la_SOURCES =  \
	$(VALASOURCES:.vala=.c)	\
	$(VALASOURCES:.vala=.h)

VALASOURCES = \
	curve.vala \
	experiment.vala \
	intersection.vala \
	part.vala \
	ptype.vala \
	run.vala \
	surface.vala \
	track.vala \
	types.vala \
	vector.vala \
	vertex.vala \
	volume-ball.vala \
	volume-box.vala \
	volume-cylinder.vala \
	volume-simple.vala \
	volume.vala \
	plugin-manager.vala

BUILT_SOURCES = vala-ccode
VALAFLAGS=
VALAPKGS = ../builder/builder.vapi --pkg gsl --pkg gmodule-2.0
@VALA_CCODE_RULES@
