#SUBDIRS = math physics core main . tests
SUBDIRS = .

lib_LTLIBRARIES = libucntracker.la 
libucntracker_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) \
			$(top_builddir)/valartl/libvalartl.la 
libucntracker_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) -I$(top_srcdir)/valartl

#			math/libmath.la \
#			physics/libphysics.la \
#			core/libcore.la \
#			main/libmain.la


BUILT_SOURCES = vala-ccode
VALAFLAGS= --library=ucntracker --basedir=$(top_srcdir)/ucntracker --vapidir=$(top_srcdir)/valartl
VALADOCFLAGS = -o Documentation --package-name=ucntracker --vapidir=$(top_srcdir)/valartl
VALAPKGS = --pkg gmodule-2.0 --pkg valartl --pkg gsl

libucntracker_la_SOURCES = \
	$(VALASOURCES:.vala=.c)\
	$(VALASOURCES:.vala=.h)

VALASOURCES = \
	main/main.vala \
	main/plugin-manager.vala \
	math/const.vala \
	math/eulerangles.vala \
	math/vector.vala \
	math/quaternion.vala \
	math/surface.vala \
	core/volume.vala \
	core/group.vala \
	core/field.vala \
	core/experiment.vala \
	core/intersector.vala \
	core/run.vala \
	core/evolve.vala \
	core/part.vala \
	volume/volume-simple.vala \
	volume/volume-boolean.vala \
	volume/volume-ball.vala \
	volume/volume-torus.vala \
	volume/volume-box.vala \
	volume/volume-cylinder.vala \
	field/accel.vala \
	field/barrier.vala \
	physics/random.vala \
	physics/vertex.vala \
	physics/ptype.vala \
	physics/neutron.vala \
	physics/track.vala \
	physics/transport.vala

@VALA_CCODE_RULES@
if ENABLE_VALADOC
@VALA_DOC_RULES@
BUILT_SOURCES+=vala-doc
endif
vapi_DATA = ucntracker.vapi ucntracker.deps
vapidir=$(datadir)/vala/vapi

ucntracker.deps: 
	echo gmodule-2.0 > $@
	echo valartl >> $@

EXTRA_CLEAN = ucntracker.deps ucntracker.vapi
