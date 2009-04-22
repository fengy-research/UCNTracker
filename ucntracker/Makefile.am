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
VALAFLAGS= --library=ucntracker --basedir=$(top_srcdir)/ucntracker --vapidir=$(top_srcdir)/valartl --vapidir=$(top_srcdir)/vapi
VALAPKGS = --pkg gmodule-2.0 --pkg valartl --pkg gsl
libucntracker_la_SOURCES = \
	$(VALASOURCES:.vala=.c)\
	$(VALASOURCES:.vala=.h)

VALASOURCES = \
	main/main.vala \
	main/plugin-manager.vala \
	math/vector.vala \
	math/surface.vala \
	math/curve.vala \
	core/types.vala \
	volume/volume.vala \
	volume/volume-simple.vala \
	volume/volume-boolean.vala \
	volume/volume-ball.vala \
	volume/volume-torus.vala \
	volume/volume-box.vala \
	volume/volume-cylinder.vala \
	field/field.vala \
	field/gravity.vala \
	field/magnetic.vala \
	core/experiment.vala \
	core/intersector.vala \
	core/run.vala \
	core/evolve.vala \
	core/part.vala \
	physics/random.vala \
	physics/vertex.vala \
	physics/ptype.vala \
	physics/neutron.vala \
	physics/track.vala \
	physics/transport.vala

@VALA_CCODE_RULES@
vapi_DATA = ucntracker.vapi ucntracker.deps
vapidir=$(datadir)/vala/vapi

#ucntracker.vapi: \
#math/math.vapi \
#physics/physics.vapi \
#core/core.vapi \
#main/main.vapi
#	cat $^ > $@

ucntracker.deps: 
	echo gmodule-2.0 > $@
	echo valartl >> $@

EXTRA_CLEAN = ucntracker.deps ucntracker.vapi
