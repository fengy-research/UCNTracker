LDADD = $(GLIB_LIBS) $(top_builddir)/gtkbuilder/libgtkbuilder.la
AM_CPPFLAGS = $(GLIB_CFLAGS) -I$(top_srcdir)

VAPIDEPENDS = $(top_srcdir)/gtkbuilder/builder.vapi

noinst_PROGRAMS = test

include $(top_srcdir)/Makefile.tests
