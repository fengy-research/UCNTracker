SUBDIRS = . tests

VAPINAME = geometry
VALASOURCES = \
	surface.vala \
	volume-simple.vala \
	volume-box.vala \
	volume-ball.vala \
	volume-cylinder.vala \
	geometry.vala 

VAPIDEPENDS = 

noinst_LTLIBRARIES = libgeometry.la
libgeometry_la_SOURCES = $(COMPILEDSOURCES)

include ../Makefile.plugin
