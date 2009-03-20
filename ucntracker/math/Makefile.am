noinst_LTLIBRARIES = libmath.la
libmath_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS)
libmath_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS)  -I$(top_srcdir) -I$(top_srcdir)/ucntracker -DG_LOG_DOMAIN=\"UCNTracker\" -DINFO=

libmath_la_SOURCES =  \
	$(VALASOURCES:.vala=.c)	\
	$(VALASOURCES:.vala=.h)

VALASOURCES = \
	vector.vala \
	surface.vala \
	curve.vala \
	math.vala 

BUILT_SOURCES = vala-ccode
VALAFLAGS= --library=math --basedir=$(top_srcdir)/ucntracker --vapidir=$(top_srcdir)/vapi
VALAPKGS = --pkg gmodule-2.0
@VALA_CCODE_RULES@

EXTRA_DIST = $(VALASOURCES) vala-ccode math.vapi
mathinclude_HEADERS =  $(VALASOURCES:.vala=.h)
mathincludedir = $(includedir)/ucntracker/math
