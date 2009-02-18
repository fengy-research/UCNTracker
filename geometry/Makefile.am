
VALASOURCES = types.vala vector.vala volume.vala volume-intersect.vala
noinst_LTLIBRARIES = libgeometry.la 

libgeometry_la_SOURCES=$(VALASOURCES:.vala=.c) \
					   $(VALASOURCES:.vala=.h)
libgeometry_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) \
				-I$(top_srcdir) -I$(top_builddir)
				-include config.h \
libgeometry_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS) \
				-l$(top_builddir)/gtkbuilder/libgtkbuilder.la

BUILT_SOURCES = vala-stamp

vala-stamp: $(VALASOURCES)
	$(VALAC) --library=geometry --basedir=$(top_builddir) -C $^ ../gtkbuilder/builder.vapi --pkg gsl
