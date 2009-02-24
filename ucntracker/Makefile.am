SUBDIRS = core geometry device . tests

VALASOURCES = ucntracker.vala

PLUGIN_LA_FILES =  geometry/libgeometry.la \
				   device/libdevice.la 

PLUGIN_VAPI_FILES =  geometry/geometry.vapi \
				device/device.vapi

lib_LTLIBRARIES = libucntracker.la 

libucntracker_la_SOURCES =  \
				$(VALASOURCES:.vala=.c) \
				$(VALASOURCES:.vala=.h)

libucntracker_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) \
			-I$(top_srcdir) -I$(top_builddir) \
			-include config.h

libucntracker_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) \
			core/libcore.la \
			 $(PLUGIN_LA_FILES)

libucntracker_la_LDFLAGS = 

BUILT_SOURCES = vala-stamp

vala-stamp: $(VALASOURCES) core/core.vapi $(PLUGIN_VAPI_FILES)
	$(VALAC) --library=ucntracker --basedir=$(top_builddir) -C $(VALASOURCES) core/core.vapi
	cat core/core.vapi $(PLUGIN_VAPI_FILES) >> ucntracker.vapi
	touch $@
