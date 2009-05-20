
VALAPKGS = --pkg ucntracker --pkg ucntracker-vis
noinst_PROGRAMS = sample-volume scence-editor

sample_volume_SOURCES = sample-volume.c
sample_volume_LDADD = $(NONVIS_PROGRAM_LIBS)
sample_volume_CFLAGS = $(NONVIS_PROGRAM_CFLAGS)
scence_editor_SOURCES = scence-editor.c
scence_editor_LDADD = $(VIS_PROGRAM_LIBS)
scence_editor_CFLAGS = $(VIS_PROGRAM_CFLAGS)

BUILT_SOURCES = sample-volume.c scence-editor.c
SUFFIXES = .vala .c

.vala.c:
	$(VALAC) -C $(VALAFLAGS) $< $(VALAPKGS)
	touch $@

EXTRA_DIST = *.vala

