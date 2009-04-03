
noinst_LTLIBRARIES = libcore.la
libcore_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS)
libcore_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS)  -I$(top_srcdir) -I$(top_srcdir)/ucntracker -DG_LOG_DOMAIN=\"UCNTracker\" -DINFO=

libcore_la_SOURCES =  \
	$(VALASOURCES:.vala=.c)	\
	$(VALASOURCES:.vala=.h)

VALASOURCES = \
	types.vala \
	volume.vala \
	volume-simple.vala \
	volume-boolean.vala \
	volume-ball.vala \
	volume-box.vala \
	volume-cylinder.vala \
	experiment.vala \
	intersection.vala \
	run.vala \
	vertex.vala \
	evolve.vala \
	track.vala \
	field.vala \
	part.vala \
	core.vala 

BUILT_SOURCES = vala-ccode
VALAFLAGS= --library=core --basedir=$(top_srcdir)/ucntracker --vapidir=$(top_srcdir)/vapi
VALAPKGS = ../math/math.vapi ../physics/physics.vapi --pkg gsl \
	--pkg gmodule-2.0 --pkg valartl
@VALA_CCODE_RULES@

EXTRA_DIST = $(VALASOURCES) vala-ccode core.vapi
coreinclude_HEADERS =  $(VALASOURCES:.vala=.h)
coreincludedir = $(includedir)/ucntracker/core
