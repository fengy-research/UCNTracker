include ../Makefile.tests

LDADD = ../libucntracker.la $(GTK_LIBS) $(GTKGL_LIBS) \
../visualize/libvisualize.la

VAPIDEPENDS = ../physics/physics.vapi ../core/core.vapi \
../builder/builder.vapi ../library/init.vapi --pkg gtk+-2.0 \
../visualize/visualize.vapi \
--pkg gtkglext-1.0 --pkg gl --pkg glu

AM_CPPFLAGS += $(GTK_CFLAGS) $(GTKGL_CFLAGS)

noinst_PROGRAMS = \
	test-gtk

