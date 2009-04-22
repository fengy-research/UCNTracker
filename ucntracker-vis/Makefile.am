SUBDIRS = .

lib_LTLIBRARIES = libucntracker-vis.la
libucntracker_vis_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) $(GTK_LIBS) $(GTKGL_LIBS)
libucntracker_vis_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) $(GTK_CFLAGS) \
$(GTKGL_CFLAGS) -I$(top_srcdir) -I$(top_srcdir)/ucntracker
-I$(top_srcdir)/ucntracker-vis -DG_LOG_DOMAIN=\"UCNTracker\" -DINFO=

libucntracker_vis_la_SOURCES =  \
	$(VALASOURCES:.vala=.c)	\
	$(VALASOURCES:.vala=.h)

VALASOURCES = \
	camera.vala \
	renderer.vala 

BUILT_SOURCES = vala-ccode

VALAFLAGS= --library=ucntracker-vis --basedir=$(top_srcdir)/ucntracker-vis \
	--vapidir=$(top_srcdir)/vapi --vapidir=$(top_srcdir)/ucntracker
VALAPKGS = --pkg ucntracker \
	--pkg glu --pkg gl --pkg gtkglext-1.0 --pkg gtk+-2.0

vapi_DATA = ucntracker-vis.vapi ucntracker-vis.deps
vapidir=$(datadir)/vala/vapi

@VALA_CCODE_RULES@

EXTRA_DIST = $(VALASOURCES) vala-ccode ucntracker-vis.vapi
visualizeinclude_HEADERS =  $(VALASOURCES:.vala=.h)
visualizeincludedir = $(includedir)/ucntracker-vis

ucntracker-vis.deps:
	echo gtk+-2.0 > $@
	echo gtkglext-1.0 >> $@
	echo gl >> $@
	echo glu >> $@
	echo ucntracker >> $@
