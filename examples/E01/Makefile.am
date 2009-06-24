VALASOURCES = main.vala

noinst_PROGRAMS = example-01
example_01_SOURCES = main.c
BUILT_SOURCES = vala-ccode
example_01_CPPFLAGS = $(VIS_PROGRAM_CFLAGS)
example_01_LDADD = $(VIS_PROGRAM_LIBS)
VALAPKGS = --pkg ucntracker-vis-1.0
@VALA_CCODE_RULES@
EXTRA_DIST = $(VALASOURCES) vala-ccode
