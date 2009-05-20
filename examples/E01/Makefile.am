VALASOURCES = main.vala

noinst_PROGRAMS = example-01
example_01_SOURCES = main.c main.h
BUILT_SOURCES = vala-ccode
example_01_CPPFLAGS = $(NONVIS_PROGRAM_CFLAGS)
example_01_LDADD = $(NONVIS_PROGRAM_LIBS)
VALAPKGS = --pkg ucntracker
@VALA_CCODE_RULES@
EXTRA_DIST = $(VALASOURCES) vala-ccode
