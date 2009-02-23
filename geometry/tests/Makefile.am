LDADD = $(GLIB_LIBS) \
		$(GSL_LIBS) \
		$(top_builddir)/geometry/libplugin.la \
		$(top_builddir)/gtkbuilder/libgtkbuilder.la

AM_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS) -I$(top_srcdir)

VAPIDEPENDS = $(top_srcdir)/geometry/libgeometry.vapi \
			$(top_srcdir)/gtkbuilder/libgtkbuilder.vapi \
			--pkg gsl

noinst_PROGRAMS = test-builder test-vector test-volume test-grad test-box test-volumes

include $(top_srcdir)/Makefile.tests
