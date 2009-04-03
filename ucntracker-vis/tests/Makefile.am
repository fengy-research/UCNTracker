include ../../Makefile.tests

LDADD = ../../ucntracker/libucntracker.la ../../valartl/libvalartl.la $(GTK_LIBS) $(GTKGL_LIBS) \
../libucntracker-vis.la

VALAFLAGS = --vapidir=.. --vapidir=../../vapi --vapidir=../../ucntracker
VALAPKGS = --pkg ucntracker-vis

AM_CPPFLAGS += $(GTK_CFLAGS) $(GTKGL_CFLAGS) -I../

noinst_PROGRAMS = \
	test-gtk

EXTRA_DIST += *.vala
