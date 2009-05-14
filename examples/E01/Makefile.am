VALASOURCES = main.vala
UCN_CFLAGS = -I$(top_srcdir)/valartl -I$(top_srcdir)/ucntracker $(GLIB_CFLAGS) $(GSL_CFLAGS)
UCN_LIBS = $(GLIB_LIBS) $(GSL_LIBS) \
$(top_builddir)/ucntracker/libucntracker.la

noinst_PROGRAMS = example-01
example_01_SOURCES = main.c main.h
BUILT_SOURCES = vala-ccode
example_01_CPPFLAGS = $(UCN_CFLAGS)
example_01_LDADD = $(UCN_LIBS)
VALAFLAGS = --vapidir=$(top_srcdir)/ucntracker
VALAPKGS = --pkg ucntracker
@VALA_CCODE_RULES@
EXTRA_DIST = $(VALASOURCES) vala-ccode
