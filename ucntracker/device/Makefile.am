SUBDIRS = . tests

PLUGIN_NAME = device
noinst_LTLIBRARIES = libdevice.la
libdevice_la_SOURCES = $(COMPILEDSOURCES)

VALASOURCES = part.vala device.vala
VAPIDEPENDS = ../geometry/libgeometry.vapi

include $(top_srcdir)/Makefile.plugin
