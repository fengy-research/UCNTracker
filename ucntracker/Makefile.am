SUBDIRS = math physics core main . tests

lib_LTLIBRARIES = libucntracker.la 
libucntracker_la_SOURCES = 
libucntracker_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) \
			$(top_builddir)/valartl/libvalartl.la \
			math/libmath.la \
			physics/libphysics.la \
			core/libcore.la \
			main/libmain.la


vapi_DATA = ucntracker.vapi ucntracker.deps
vapidir=$(datadir)/vala/vapi

ucntracker.vapi: \
math/math.vapi \
physics/physics.vapi \
core/core.vapi \
main/main.vapi
	cat $^ > $@

ucntracker.deps: 
	echo gmodule-2.0 > $@
	echo valartl >> $@

EXTRA_CLEAN = ucntracker.deps ucntracker.vapi
