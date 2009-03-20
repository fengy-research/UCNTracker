include ../../Makefile.tests

LDADD = ../../ucntracker/libucntracker.la $(GTK_LIBS) $(GTKGL_LIBS) \
../libucntracker-vis.la

VAPIDEPENDS = ../../ucntracker/ucntracker.vapi \
../ucntracker-vis.vapi \
--pkg gtk+-2.0 \
--pkg gtkglext-1.0 --pkg gl --pkg glu

AM_CPPFLAGS += $(GTK_CFLAGS) $(GTKGL_CFLAGS) -I../

noinst_PROGRAMS = \
	test-gtk

EXTRA_DIST += *.vala
