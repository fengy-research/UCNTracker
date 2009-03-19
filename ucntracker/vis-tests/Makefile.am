include ../Makefile.tests

LDADD = ../libucntracker.la $(GTK_LIBS)

VAPIDEPENDS = ../physics/physics.vapi ../core/core.vapi \
../builder/builder.vapi ../library/init.vapi --pkg gtk+-2.0

AM_CPPFLAGS += $(GTK_CFLAGS)

noinst_PROGRAMS = \
	test-gtk

