VALASOURCES = main.vala

noinst_PROGRAMS = example-01
example_01_SOURCES = main.c main.h
BUILT_SOURCES = vala-ccode
example_01_CPPFLAGS = $(VIS_PROGRAM_CFLAGS)
example_01_LDADD = $(VIS_PROGRAM_LIBS)
VALAPKGS = --pkg ucntracker --pkg ucntracker-vis
@VALA_CCODE_RULES@
EXTRA_DIST = $(VALASOURCES) vala-ccode
