include ../Makefile.vars
SUBDIRS = .

lib_LTLIBRARIES = libucntracker-vis.la
libucntracker_vis_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) $(GTK_CFLAGS) \
	$(GTKGL_CFLAGS) $(YAML_CFLAGS) $(ENDF_CFLAGS) $(UCNTRACKER_CFLAGS) \
	-DG_LOG_DOMAIN=\"UCNTracker\" -DINFO=

libucntracker_vis_la_LDFLAGS = -g
libucntracker_vis_la_SOURCES =  \
	$(VALASOURCES:.vala=.c) \
	ucntracker-vis-1.0.h

VALASOURCES = \
	main.vala \
	vis-simulation.vala \
	camera.vala \
	renderer.vala \
	tracer.vala \
	vertex-editor.vala

BUILT_SOURCES = vala-ccode vala-doc

VALAFLAGS= -g --library=ucntracker-vis-1.0 -H ucntracker-vis-1.0.h \
	$(YAML_VALAFLAGS) \
	--vapidir=../ucntracker
VALADOCFLAGS = --package-name=ucntracker-vis-1.0 -o Documentation 
VALAPKGS = --pkg ucntracker-1.0 \
	--pkg gl --pkg glu --pkg gtkglext-1.0 --pkg gtk+-2.0

vapi_DATA = ucntracker-vis-1.0.vapi ucntracker-vis-1.0.deps
vapidir=$(datadir)/vala/vapi

vala-ccode: $(VALASOURCES)
	$(VALAC) $(VALAFLAGS) -C $^ $(VALAPKGS) 
	echo gtk+-2.0 > ucntracker-vis-1.0.deps
	echo ucntracker-1.0 >> ucntracker-vis-1.0.deps
	touch $@

if ENABLE_VALADOC
@VALA_DOC_RULES@
else
vala-doc:
	mkdir -p Documentation
	touch vala-doc;
endif

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = ucntracker-vis-1.0.pc

EXTRA_DIST = $(VALASOURCES) \
             vala-ccode \
             ucntracker-vis-1.0.vapi \
             ucntracker-vis-1.0.deps \
             ucntracker-vis-1.0.pc.in \
             vala-doc


include_HEADERS =  ucntracker-vis-1.0.h

MAINTAINERCLEANFILES = $(VALASOURCES:.vala=.c) \
        ucntracker-vis-1.0.h \
        ucntracker-vis-1.0.deps \
        ucntracker-vis-1.0.vapi \
        Documentation

$(DIST_SOURCES) : vala-ccode vala-doc
