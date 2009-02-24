
noinst_LTLIBRARIES = libcore.la
libcore_la_LIBADD = $(GLIB_LIBS) $(GSL_LIBS)
libcore_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS)  -I$(top_srcdir) -I$(top_srcdir)/ucntracker -DG_LOG_DOMAIN=\"UCNTracker\" -DINFO=

libcore_la_SOURCES =  \
	$(VALASOURCES:.vala=.c)	\
	$(VALASOURCES:.vala=.h)

VALASOURCES = plugin-manager.vala

BUILT_SOURCES = vala-stamp
vala-stamp: $(VALASOURCES)
	$(VALAC) --library=core --basedir=$(top_srcdir)/ucntracker -C $^ ../builder/builder.vapi --pkg gsl
	touch $@
