VALASOURCES = main.vala

noinst_PROGRAMS = example-02
example_02_SOURCES = main.c main.h
BUILT_SOURCES = vala-ccode
example_02_CPPFLAGS = $(VIS_PROGRAM_CFLAGS)
example_02_LDADD = $(VIS_PROGRAM_LIBS)

VALAPKGS =--pkg ucntracker-vis-1.0
@VALA_CCODE_RULES@
EXTRA_DIST = $(VALASOURCES) vala-ccode
