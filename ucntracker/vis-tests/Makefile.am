include ../Makefile.tests

LDADD = ../libucntracker.la $(GTK_LIBS) $(GTKGL_LIBS) \
../visualize/libvisualize.la

VAPIDEPENDS = ../ucntracker.vapi \
../visualize/visualize.vapi \
--pkg gtk+-2.0 \
--pkg gtkglext-1.0 --pkg gl --pkg glu

AM_CPPFLAGS += $(GTK_CFLAGS) $(GTKGL_CFLAGS)

noinst_PROGRAMS = \
	test-gtk

EXTRA_DIST += *.vala
