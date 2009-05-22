#SUBDIRS = math physics core main . tests
SUBDIRS = .

lib_LTLIBRARIES = libucntracker.la 
libucntracker_la_CPPFLAGS = -DG_LOG_DOMAIN=\"UCNTracker\" $(GLIB_CFLAGS) $(GSL_CFLAGS) $(YAMLGLIB_CFLAGS)

BUILT_SOURCES = vala-ccode
VALAFLAGS= --library=ucntracker -H ucntracker.h
VALADOCFLAGS = -o Documentation --package-name=ucntracker
VALAPKGS = --pkg gmodule-2.0 --pkg libyaml-glib-1.0 --pkg gsl

libucntracker_la_SOURCES = \
	$(VALASOURCES:.vala=.c)\
	ucntracker.h

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
	math/multichannel.vala \
	math/quaternion.vala \
	math/surface.vala \
	core/volume.vala \
	core/group.vala \
	core/field.vala \
	core/experiment.vala \
	core/intersector.vala \
	core/cross-section.vala \
	core/freelength-table.vala \
	core/evolve.vala \
	core/border.vala \
	core/vertex.vala \
	core/track.vala \
	core/part.vala \
	volume/volume-simple.vala \
	volume/volume-boolean.vala \
	volume/volume-ball.vala \
	volume/volume-torus.vala \
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
	echo gmodule-2.0 > ucntracker.deps
	echo libyaml-glib-1.0 >> ucntracker.deps
	echo gsl >> ucntracker.deps
	touch vala-ccode

if ENABLE_VALADOC
@VALA_DOC_RULES@
else
vala-doc:
	touch vala-doc;
endif
BUILT_SOURCES+=vala-doc

vapi_DATA = ucntracker.vapi
vapidir=$(datadir)/vala/vapi
ucntrackerinclude_HEADERS = ucntracker.h
ucntrackerincludedir = $(includedir)/ucntracker

EXTRA_DIST = $(VALASOURCES) vala-ccode ucntracker.vapi ucntracker.gir ucntracker.deps vala-doc

$(DIST_SOURCES) : vala-ccode vala-doc

MAINTAINERCLEANFILES = $(VALASOURCES:.vala=.c) ucntracker.h \
                       ucntracker.vapi ucntracker.deps ucntracker.gir \
                       Documentation
