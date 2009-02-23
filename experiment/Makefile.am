
VALASOURCES = 

noinst_LTLIBRARIES = libexperiment.la 

libexperiment_la_SOURCES=$(VALASOURCES:.vala=.c) \
					   $(VALASOURCES:.vala=.h)
libexperiment_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) \
				-I$(top_srcdir) -I$(top_builddir) \
				-include config.h
libexperiment_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) \
				../geometry/libgeometry.la

libexperiment_la_LDFLAGS = 

BUILT_SOURCES = vala-stamp

vala-stamp: $(VALASOURCES)
	$(VALAC) --library=libexperiment --basedir=$(top_builddir) -C $^ --pkg gsl
