#SUBDIRS = math physics core main . tests
SUBDIRS = .

YAMLGLIB_LIBS = -L../libyaml-glib -lyaml-glib
YAMLGLIB_CFLAGS = -I../libyaml-glib -I../libyaml/include

lib_LTLIBRARIES = libucntracker.la 
libucntracker_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) \
	$(YAMLGLIB_LIBS)
libucntracker_la_CPPFLAGS = -DG_LOG_DOMAIN=\"UCNTracker\" $(GLIB_CFLAGS) $(GSL_CFLAGS) $(YAMLGLIB_CFLAGS)

BUILT_SOURCES = vala-ccode
VALAFLAGS= --library=ucntracker --vapidir=$(top_srcdir)/libyaml-glib -H ucntracker.h
VALADOCFLAGS = -o Documentation --package-name=ucntracker --vapidir=$(top_srcdir)/libyaml-glib
VALAPKGS = --pkg gmodule-2.0 --pkg libyaml-glib-1.0 --pkg gsl

libucntracker_la_SOURCES = \
	$(VALASOURCES:.vala=.c)\
	ucntracker.h

VALASOURCES = \
	main/main.vala \
	main/error.vala \
	main/plugin-manager.vala \
	math/units.vala \
	math/eulerangles.vala \
	math/vector.vala \
	math/random.vala \
	math/multichannel.vala \
	math/quaternion.vala \
	math/surface.vala \
	core/buildable.vala \
	core/builder.vala \
	core/volume.vala \
	core/group.vala \
	core/field.vala \
	core/experiment.vala \
	core/intersector.vala \
	core/crosssection.vala \
	core/freelength-table.vala \
	core/run.vala \
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
	physics/neutron.vala \
	physics/cold-neutron.vala \
	physics/ultracold-neutron.vala \
	physics/transport.vala

@VALA_CCODE_RULES@
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

ucntracker.deps: 
	echo gmodule-2.0 > $@
	echo gsl >> $@

EXTRA_DIST = $(VALASOURCES) vala-ccode ucntracker.vapi ucntracker.deps vala-doc
EXTRA_CLEAN = ucntracker.deps ucntracker.vapi
