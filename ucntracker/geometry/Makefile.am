SUBDIRS = . tests

VALASOURCES = \
	types.vala \
	vector.vala \
	surface.vala \
	volume.vala \
	intersection.vala \
	volume-simple.vala \
	volume-box.vala \
	volume-ball.vala \
	volume-cylinder.vala \
	geometry.vala 

VAPIDEPENDS = 
noinst_LTLIBRARIES = libgeometry.la
libgeometry_la_SOURCES = $(COMPILEDSOURCES)

include $(top_srcdir)/Makefile.plugin
