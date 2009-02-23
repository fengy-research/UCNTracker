
VALASOURCES = ucntracker.vala
PLUGIN_LA_FILES = $(top_builddir)/gtkbuilder/libgtkbuilder.la \
				$(top_builddir)/geometry/libplugin.la \
				$(top_builddir)/device/libplugin.la 

PLUGIN_VAPI_FILES = $(top_builddir)/gtkbuilder/libgtkbuilder.vapi \
				$(top_builddir)/geometry/libgeometry.vapi \
				$(top_builddir)/device/libdevice.vapi

lib_LTLIBRARIES = libucntracker.la 

libucntracker_la_SOURCES=$(VALASOURCES:.vala=.c) \
		 				  $(VALASOURCES:.vala=.h)
libucntracker_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) \
			-I$(top_srcdir) -I$(top_builddir) \
			-include config.h

libucntracker_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) \
			 $(PLUGIN_LA_FILES)

libucntracker_la_LDFLAGS = 

BUILT_SOURCES = vala-stamp

vala-stamp: $(VALASOURCES)
	$(VALAC) --library=ucntracker --basedir=$(top_builddir) -C $^ $(PLUGIN_VAPI_FILES)
	cat $(PLUGIN_VAPI_FILES) >> ucntracker.vapi
	touch $@
