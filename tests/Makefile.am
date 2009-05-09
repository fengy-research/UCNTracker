include ../Makefile.tests

LDADD = ../ucntracker/libucntracker.la \
../valartl/libvalartl.la \
../ucntracker-vis/libucntracker-vis.la \
$(GTK_LIBS) $(GTKGL_LIBS)

VALAFLAGS = --vapidir=../vapi \
	--vapidir=../ucntracker \
	--vapidir=../ucntracker-vis

VALAPKGS = --pkg ucntracker-vis

AM_CPPFLAGS += $(GTK_CFLAGS) $(GTKGL_CFLAGS) -I../ucntracker -I../ucntracker-vis -I../valartl

noinst_PROGRAMS = \
	test-gtk \
	test-rng

EXTRA_DIST += *.vala
