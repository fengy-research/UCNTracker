#SUBDIRS = tests

noinst_LTLIBRARIES = libbuilder.la
libbuilder_la_LIBADD = $(GLIB_LIBS) 
libbuilder_la_CPPFLAGS = $(GLIB_CFLAGS) $(GSL_CFLAGS)  -I$(top_srcdir) -I$(top_srcdir)/ucntracker -DG_LOG_DOMAIN=\"UCNTracker\" -DINFO=

libbuilder_la_SOURCES =  \
	gtkbuildable.h \
	gtkbuilder.h \
	gtkbuilderprivate.h \
	gtkbuildable.c \
	gtkbuilder.c \
	gtkbuilderparser.c \
	nls.h

