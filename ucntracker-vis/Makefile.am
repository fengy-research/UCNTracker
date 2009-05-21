SUBDIRS = .

lib_LTLIBRARIES = libucntracker-vis.la
libucntracker_vis_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) $(GTK_CFLAGS) \
	$(GTKGL_CFLAGS) $(YAMLGLIB_CFLAGS) $(UCNTRACKER_CFLAGS) \
	-DG_LOG_DOMAIN=\"UCNTracker\" -DINFO=

libucntracker_vis_la_SOURCES =  \
	$(VALASOURCES:.vala=.c) \
	ucntracker-vis.h

VALASOURCES = \
	camera.vala \
	renderer.vala \
	tracer.vala \
	vertex-editor.vala

BUILT_SOURCES = vala-ccode vala-doc

VALAFLAGS= --library=ucntracker-vis -H ucntracker-vis.h
VALADOCFLAGS = --package-name=ucntracker-vis -o Documentation 
VALAPKGS = --pkg ucntracker \
	--pkg glu --pkg gl --pkg gtkglext-1.0 --pkg gtk+-2.0

vapi_DATA = ucntracker-vis.vapi ucntracker-vis.deps
vapidir=$(datadir)/vala/vapi

vala-ccode: $(VALASOURCES)
	$(VALAC) $(VALAFLAGS) -C $^ $(VALAPKGS) 
	echo gtk+-2.0 > ucntracker-vis.deps
	echo gtkglext-1.0 >> ucntracker-vis.deps
	echo gl >> ucntracker-vis.deps
	echo glu >> ucntracker-vis.deps
	echo ucntracker >> ucntracker-vis.deps
	touch $@

if ENABLE_VALADOC
@VALA_DOC_RULES@
else
vala-doc:
	touch vala-doc;
endif

EXTRA_DIST = $(VALASOURCES) vala-ccode ucntracker-vis.gir ucntracker-vis.vapi ucntracker-vis.deps vala-doc

visualizeinclude_HEADERS =  ucntracker-vis.h
visualizeincludedir = $(includedir)/ucntracker

MAINTAINERCLEANFILES = $(VALASOURCES:.vala=.c) ucntracker-vis.h \
     ucntracker-vis.deps ucntracker-vis.vapi ucntracker-vis.gir \
     Documentation

$(DIST_SOURCES) : vala-ccode vala-doc
