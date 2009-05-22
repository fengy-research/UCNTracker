VALASOURCES = main.vala

noinst_PROGRAMS = mirror
mirror_SOURCES = main.c 
BUILT_SOURCES = vala-ccode
mirror_CPPFLAGS = $(VIS_PROGRAM_CFLAGS)
mirror_LDADD = $(VIS_PROGRAM_LIBS)

VALAPKGS = --pkg ucntracker --pkg gtk+-2.0 --pkg ucntracker-vis --pkg gsl
@VALA_CCODE_RULES@
EXTRA_DIST = $(VALASOURCES) vala-ccode
