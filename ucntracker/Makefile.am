SUBDIRS = builder core geometry device . tests

VALASOURCES = ucntracker.vala

PLUGIN_LA_FILES =  builder/libbuilder.la \
				core/libcore.la \
				geometry/libgeometry.la \
				   device/libdevice.la 

PLUGIN_VAPI_FILES =  \
				builder/builder.vapi \
				core/core.vapi \
				geometry/geometry.vapi \
				device/device.vapi

lib_LTLIBRARIES = libucntracker.la 

libucntracker_la_SOURCES =  \
				$(VALASOURCES:.vala=.c) \
				$(VALASOURCES:.vala=.h)

libucntracker_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) \
			-I$(top_srcdir) -I$(top_builddir) \
			-include config.h

libucntracker_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) \
			 $(PLUGIN_LA_FILES)

libucntracker_la_LDFLAGS = 

BUILT_SOURCES = vala-stamp

vala-stamp: $(VALASOURCES) $(PLUGIN_VAPI_FILES)
	$(VALAC) --library=ucntracker --basedir=$(top_builddir) -C $(VALASOURCES) $(PLUGIN_VAPI_FILES)
	cat $(PLUGIN_VAPI_FILES) >> ucntracker.vapi
	touch $@
