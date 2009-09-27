#SUBDIRS = math physics core main . tests
SUBDIRS = .

lib_LTLIBRARIES = libucntracker.la 
libucntracker_la_CPPFLAGS = -DG_LOG_DOMAIN=\"UCNTracker\" $(GLIB_CFLAGS) $(GSL_CFLAGS) $(YAML_CFLAGS) $(ENDF_CFLAGS)

libucntracker_la_LIBADD = $(YAML_LIBS)
libucntracker_la_LDFLAGS = -g 

BUILT_SOURCES = vala-ccode
VALAFLAGS= --library=ucntracker-1.0 -H ucntracker-1.0.h $(YAML_VALAFLAGS)
VALADOCFLAGS = -o Documentation --package-name=ucntracker-1.0
VALAPKGS = --pkg gmodule-2.0 --pkg libyaml-glib-1.0 --pkg gsl

libucntracker_la_SOURCES = \
	$(VALASOURCES:.vala=.c) \
	ucntracker-1.0.h

SURFACES = \
	object/surface/circle.vala \
	object/surface/rectangle.vala \
	object/surface/sphere.vala \
	object/surface/torus.vala \
	object/surface/tube.vala 

VOLUMES = \
	object/volume/simple.vala \
	object/volume/ball.vala \
	object/volume/boolean.vala \
	object/volume/box.vala \
	object/volume/cylinder.vala \
	object/volume/donut.vala

FIELDS = \
	object/field/accel.vala \
	object/field/barrier.vala \
	object/field/custom.vala 
SECTIONS = 
#	Temporarily disable endf dependency
#	object/cross-section/elastic.vala

VALASOURCES = \
	main/main.vala \
	main/error.vala \
	main/plugin-manager.vala \
	main/simulation.vala \
	main/run.vala \
	math/units.vala \
	math/eulerangles.vala \
	math/vector.vala \
	math/random.vala \
	math/quaternion.vala \
	core/freelength-table.vala \
	core/transformable.vala \
	core/evolve.vala \
	core/vertex.vala \
	core/track.vala \
	object/experiment.vala \
	object/foil.vala \
	object/part.vala \
	object/border.vala \
	object/cross-section.vala $(SECTIONS) \
	object/surface.vala $(SURFACES) \
	object/volume.vala $(VOLUMES) \
	object/field.vala $(FIELDS) \
	physics/neutron.vala \
	physics/cold-neutron.vala \
	physics/ultracold-neutron.vala \
	physics/transport.vala

vala-ccode: $(VALASOURCES)
	$(VALAC) $(VALAFLAGS) -C $^ $(VALAPKGS) 
	echo gmodule-2.0 > ucntracker-1.0.deps
	echo libyaml-glib-1.0 >> ucntracker-1.0.deps
	echo gsl >> ucntracker-1.0.deps
	touch vala-ccode

if ENABLE_VALADOC
@VALA_DOC_RULES@
else
vala-doc:
	mkdir -p Documentation
	touch vala-doc;
endif
BUILT_SOURCES+=vala-doc

vapi_DATA = ucntracker-1.0.vapi ucntracker-1.0.deps
vapidir=$(datadir)/vala/vapi
pkginclude_HEADERS = ucntracker-1.0.h
pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = ucntracker-1.0.pc

EXTRA_DIST = $(VALASOURCES) \
             vala-ccode \
             ucntracker-1.0.vapi \
             ucntracker-1.0.deps \
             ucntracker-1.0.pc.in \
             vala-doc

$(DIST_SOURCES) : vala-ccode vala-doc

MAINTAINERCLEANFILES = $(VALASOURCES:.vala=.c) ucntracker-1.0.h \
                       ucntracker-1.0.vapi \
                       ucntracker-1.0.deps \
                       Documentation
