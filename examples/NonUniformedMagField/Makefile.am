VALASOURCES = main1.vala

noinst_PROGRAMS = NonUniformedMagField
NonUniformedMagField_SOURCES = main1.c
BUILT_SOURCES = vala-ccode
NonUniformedMagField_CPPFLAGS = $(VIS_PROGRAM_CFLAGS)
NonUniformedMagField_LDADD = $(VIS_PROGRAM_LIBS)

VALAPKGS = --pkg ucntracker-vis-1.0
@VALA_CCODE_RULES@
EXTRA_DIST = $(VALASOURCES) vala-ccode
