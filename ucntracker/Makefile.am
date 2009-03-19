SUBDIRS = builder physics core library . tests vis-tests

lib_LTLIBRARIES = libucntracker.la 
libucntracker_la_SOURCES = 
libucntracker_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) \
			builder/libbuilder.la \
			physics/libphysics.la \
			core/libcore.la \
			library/libinit.la

vapi_DATA = ucntracker.vapi
vapidir=$(datadir)/vala/vapi

ucntracker.vapi: physics/physics.vapi core/core.vapi builder/builder.vapi library/init.vapi
	cat $^ > $@
