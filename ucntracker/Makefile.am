SUBDIRS = builder math physics core main .

lib_LTLIBRARIES = libucntracker.la 
libucntracker_la_SOURCES = 
libucntracker_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) \
			builder/libbuilder.la \
			math/libmath.la \
			physics/libphysics.la \
			core/libcore.la \
			main/libmain.la


vapi_DATA = ucntracker.vapi
vapidir=$(datadir)/vala/vapi

ucntracker.vapi: \
math/math.vapi \
physics/physics.vapi \
core/core.vapi \
builder/builder.vapi \
main/main.vapi
	cat $^ > $@
