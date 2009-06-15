<<<<<<< HEAD:examples/NonUniformedMagField/Makefile.am
VALASOURCES = main1.vala

noinst_PROGRAMS = NonUniformedMagField
NonUniformedMagField_SOURCES = main1.c
=======
VALASOURCES = main.vala

noinst_PROGRAMS = NonUniformedMagField
NonUniformedMagField_SOURCES = main.c
>>>>>>> origin/field-rework:examples/NonUniformedMagField/Makefile.am
BUILT_SOURCES = vala-ccode
NonUniformedMagField_CPPFLAGS = $(VIS_PROGRAM_CFLAGS)
NonUniformedMagField_LDADD = $(VIS_PROGRAM_LIBS)

<<<<<<< HEAD:examples/NonUniformedMagField/Makefile.am
VALAPKGS = --pkg ucntracker-vis-1.0
=======
VALAPKGS = --pkg ucntracker --pkg gtk+-2.0 --pkg ucntracker-vis --pkg gsl
>>>>>>> origin/field-rework:examples/NonUniformedMagField/Makefile.am
@VALA_CCODE_RULES@
EXTRA_DIST = $(VALASOURCES) vala-ccode
