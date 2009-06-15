VALASOURCES = main.vala

noinst_PROGRAMS = ProgramFolderName
ProgramFolderName_SOURCES = main.c
BUILT_SOURCES = vala-ccode
ProgramFolderName_CPPFLAGS = $(VIS_PROGRAM_CFLAGS)
ProgramFolderName_LDADD = $(VIS_PROGRAM_LIBS)

VALAPKGS = --pkg ucntracker --pkg gtk+-2.0 --pkg ucntracker-vis --pkg gsl
@VALA_CCODE_RULES@
EXTRA_DIST = $(VALASOURCES) vala-ccode
