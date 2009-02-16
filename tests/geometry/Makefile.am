LDADD = $(GLIB_LIBS) \
		$(GSL_LIBS) \
	$(top_builddir)/geometry/libgeometry.la \
	$(top_builddir)/gtkbuilder/libgtkbuilder.la
AM_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) -I$(top_srcdir)

VALACFLAGS= $(top_srcdir)/geometry/geometry.vapi $(top_srcdir)/gtkbuilder/builder.vapi --pkg gsl

noinst_PROGRAMS = test-builder test-vector test-volume

include ../Makefile.tests
