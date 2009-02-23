LDADD = $(GLIB_LIBS) $(top_builddir)/ucntracker/libucntracker.la
AM_CPPFLAGS = $(GLIB_CFLAGS) -I$(top_srcdir)

VAPIDEPENDS = $(top_srcdir)/ucntracker/ucntracker.vapi

noinst_PROGRAMS = test

include $(top_srcdir)/Makefile.tests
