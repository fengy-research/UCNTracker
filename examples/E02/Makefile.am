VALASOURCES = main.vala
UCN_CFLAGS = -I$(top_srcdir)/ucntracker -I$(top_srcdir)/ucntracker-vis -I$(top_srcdir)/valartl \
$(GLIB_CFLAGS) $(GSL_CFLAGS)
UCN_LIBS = $(GLIB_LIBS) $(GSL_LIBS) \
$(top_builddir)/ucntracker/libucntracker.la \
$(top_builddir)/ucntracker-vis/libucntracker-vis.la


noinst_PROGRAMS = example-02
example_02_SOURCES = main.c main.h
BUILT_SOURCES = vala-ccode
example_02_CPPFLAGS = $(UCN_CFLAGS) $(GTK_CFLAGS)
example_02_LDADD = $(UCN_LIBS) $(GTK_LIBS)

VALAFLAGS = --vapidir=$(top_srcdir)/ucntracker \
--vapidir=$(top_srcdir)/ucntracker-vis
VALAPKGS = --pkg ucntracker --pkg gtk+-2.0 --pkg ucntracker-vis --pkg gsl
@VALA_CCODE_RULES@
EXTRA_DIST = $(VALASOURCES) vala-ccode
