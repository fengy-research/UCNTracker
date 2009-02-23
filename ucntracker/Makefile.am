SUBDIRS = plugin-manager geometry device .

VALASOURCES = ucntracker.vala
PLUGIN_LA_FILES =  \
				plugin-manager/libplugin-manager.la \
				$(top_builddir)/gtkbuilder/libgtkbuilder.la \
				geometry/libgeometry.la \
				device/libdevice.la 

PLUGIN_VAPI_FILES =  $(PLUGIN_LA_FILES:.la=.vapi)

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

vala-stamp: $(VALASOURCES)
	$(VALAC) --library=ucntracker --basedir=$(top_builddir) -C $^ plugin-manager/libplugin-manager.vapi
	cat $(PLUGIN_VAPI_FILES) >> ucntracker.vapi
	touch $@
