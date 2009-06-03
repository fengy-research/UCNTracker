VALASOURCES = main.vala

noinst_PROGRAMS = example-03
example_03_SOURCES = main.c
BUILT_SOURCES = vala-ccode
example_03_CPPFLAGS = $(VIS_PROGRAM_CFLAGS)
example_03_LDADD = $(VIS_PROGRAM_LIBS)

VALAPKGS = --pkg ucntracker-vis-1.0
@VALA_CCODE_RULES@
EXTRA_DIST = $(VALASOURCES) vala-ccode
