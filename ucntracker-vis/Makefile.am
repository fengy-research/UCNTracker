SUBDIRS = .

lib_LTLIBRARIES = libucntracker-vis.la
libucntracker_vis_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) $(GTK_LIBS) $(GTKGL_LIBS)
libucntracker_vis_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) $(GTK_CFLAGS) \
	$(GTKGL_CFLAGS) -I$(top_srcdir) -I$(top_srcdir)/ucntracker -I$(top_srcdir)/valartl \
	-I$(top_srcdir)/ucntracker-vis -DG_LOG_DOMAIN=\"UCNTracker\" -DINFO=

libucntracker_vis_la_SOURCES =  \
	$(VALASOURCES:.vala=.c) \
	ucntracker-vis.h

VALASOURCES = \
	camera.vala \
	renderer.vala \
	tracer.vala \
	vertex-editor.vala

BUILT_SOURCES = vala-ccode

VALAFLAGS= --library=ucntracker-vis -H ucntracker-vis.h \
	--vapidir=$(top_srcdir)/vapi --vapidir=$(top_srcdir)/ucntracker
VALADOCFLAGS = --package-name=ucntracker-vis -o Documentation \
	--vapidir=$(top_srcdir)/vapi --vapidir=$(top_srcdir)/ucntracker
VALAPKGS = --pkg ucntracker \
	--pkg glu --pkg gl --pkg gtkglext-1.0 --pkg gtk+-2.0

vapi_DATA = ucntracker-vis.vapi ucntracker-vis.deps
vapidir=$(datadir)/vala/vapi

@VALA_CCODE_RULES@
if ENABLE_VALADOC
@VALA_DOC_RULES@
else
vala-doc:
	touch vala-doc;
endif
BUILT_SOURCES += vala-doc

EXTRA_DIST = $(VALASOURCES) vala-ccode ucntracker-vis.vapi ucntracker-vis.deps vala-doc
visualizeinclude_HEADERS =  ucntracker-vis.h
visualizeincludedir = $(includedir)/ucntracker

ucntracker-vis.deps:
	echo gtk+-2.0 > $@
	echo gtkglext-1.0 >> $@
	echo gl >> $@
	echo glu >> $@
	echo ucntracker >> $@

EXTRA_CLEAN = ucntracker-vis.deps ucntracker-vis.vapi
