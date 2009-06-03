#SUBDIRS = math physics core main . tests
SUBDIRS = .

lib_LTLIBRARIES = libucntracker.la 
libucntracker_la_CPPFLAGS = -DG_LOG_DOMAIN=\"UCNTracker\" $(GLIB_CFLAGS) $(GSL_CFLAGS) $(YAMLGLIB_CFLAGS)

BUILT_SOURCES = vala-ccode
VALAFLAGS= --library=ucntracker-1.0 -H ucntracker-1.0.h
VALADOCFLAGS = -o Documentation --package-name=ucntracker-1.0
VALAPKGS = --pkg gmodule-2.0 --pkg libyaml-glib-1.0 --pkg gsl

libucntracker_la_SOURCES = \
	$(VALASOURCES:.vala=.c)\
	ucntracker-1.0.h

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
	buildables/volume.vala \
	buildables/field.vala \
	buildables/experiment.vala \
	buildables/cross-section.vala \
	buildables/border.vala \
	buildables/surface.vala \
	buildables/foil.vala \
	core/freelength-table.vala \
	core/transformable.vala \
	core/evolve.vala \
	core/vertex.vala \
	core/track.vala \
	buildables/part.vala \
	volume/volume-simple.vala \
	volume/volume-boolean.vala \
	volume/volume-ball.vala \
	volume/volume-donut.vala \
	volume/volume-box.vala \
	volume/volume-cylinder.vala \
	field/accel.vala \
	field/barrier.vala \
	field/custom.vala \
	physics/neutron.vala \
	physics/cold-neutron.vala \
	physics/ultracold-neutron.vala \
	physics/transport.vala

vala-ccode: $(VALASOURCES)
	$(VALAC) $(VALAFLAGS) -C $^ $(VALAPKGS) 
	echo gmodule-2.0 > ucntracker-1.0.deps
	echo libyaml-glib-1.0 >> ucntracker-1.0.deps
	echo libendf-1.0 >> ucntracker-1.0.deps
	echo gsl >> ucntracker-1.0.deps
	touch vala-ccode

if ENABLE_VALADOC
@VALA_DOC_RULES@
else
vala-doc:
	touch vala-doc;
endif
BUILT_SOURCES+=vala-doc

vapi_DATA = ucntracker-1.0.vapi
vapidir=$(datadir)/vala/vapi
include_HEADERS = ucntracker-1.0.h


EXTRA_DIST = $(VALASOURCES) vala-ccode ucntracker.vapi ucntracker.gir ucntracker.deps vala-doc

$(DIST_SOURCES) : vala-ccode vala-doc

MAINTAINERCLEANFILES = $(VALASOURCES:.vala=.c) ucntracker-1.0.h \
                       ucntracker.vapi ucntracker.deps ucntracker.gir \
                       Documentation
