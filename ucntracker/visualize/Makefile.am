
noinst_LTLIBRARIES = libvisualize.la
libvisualize_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) $(GTK_LIBS) $(GTKGL_LIBS)
libvisualize_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) $(GTK_CFLAGS) \
$(GTKGL_CFLAGS) -I$(top_srcdir) -I$(top_srcdir)/ucntracker -DG_LOG_DOMAIN=\"UCNTracker\" -DINFO=

libvisualize_la_SOURCES =  \
	$(VALASOURCES:.vala=.c)	\
	$(VALASOURCES:.vala=.h)

VALASOURCES = \
	visualize.vala

BUILT_SOURCES = vala-ccode

VALAFLAGS= --library=visualize --basedir=$(top_srcdir)/ucntracker --vapidir=$(top_srcdir)/vapi
VALAPKGS = \
../math/math.vapi \
../builder/builder.vapi \
../physics/physics.vapi \
../core/core.vapi \
--pkg glu --pkg gl --pkg gtkglext-1.0 --pkg gtk+-2.0

@VALA_CCODE_RULES@

EXTRA_DIST = $(VALASOURCES) vala-ccode visualize.vapi
visualizeinclude_HEADERS =  $(VALASOURCES:.vala=.h)
visualizeincludedir = $(includedir)/ucntracker/visualize

