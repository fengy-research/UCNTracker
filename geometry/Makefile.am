
VALASOURCES = types.vala vector.vala volume.vala
noinst_LTLIBRARIES = libgeometry.la

libgeometry_la_SOURCES=$(VALASOURCES:.vala=.c) \
					   $(VALASOURCES:.vala=.h)
libgeometry_la_CPPFLAGS = $(GLIB_CFLAGS) \
				-I$(top_srcdir) -I$(top_builddir)
				-include config.h \
libgeometry_la_LIBADD = $(GLIB_LIBS) \
				-l$(top_builddir)/gtkbuilder/libgtkbuilder.la

BUILT_SOURCES = vala-stamp

vala-stamp: $(VALASOURCES)
	$(VALAC) -C $^ ../gtkbuilder/builder.vapi
