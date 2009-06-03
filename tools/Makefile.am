
VALAPKGS = --pkg ucntracker-vis-1.0
noinst_PROGRAMS = sample-volume scene-editor

sample_volume_SOURCES = sample-volume.c
sample_volume_LDADD = $(NONVIS_PROGRAM_LIBS)
sample_volume_CFLAGS = $(NONVIS_PROGRAM_CFLAGS)
scene_editor_SOURCES = scene-editor.c
scene_editor_LDADD = $(VIS_PROGRAM_LIBS)
scene_editor_CFLAGS = $(VIS_PROGRAM_CFLAGS)

BUILT_SOURCES = sample-volume.c scene-editor.c
SUFFIXES = .vala .c

.vala.c:
	$(VALAC) -C $(VALAFLAGS) $< $(VALAPKGS)
	touch $@

EXTRA_DIST = *.vala

