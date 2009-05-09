
VALAPKGS = --pkg ucntracker --pkg ucntracker-vis
VALAFLAGS = --vapidir=../ucntracker --vapidir=../ucntracker-vis --vapidir=../valartl
LDADD = ../ucntracker/libucntracker.la ../ucntracker-vis/libucntracker-vis.la
AM_CPPFLAGS = $(GLIB_CFLAGS) $(GTK_CFLAGS) $(GTKGL_CFLAGS) -I../ucntracker -I../valartl -I../ucntracker-vis
noinst_PROGRAMS = sample-volume scence-editor

sample_volume_SOURCES = sample-volume.c
scence_editor_SOURCES= scence-editor.c

SUFFIXES = .vala .c

.vala.c:
	$(VALAC) -C $(VALAFLAGS) $< $(VALAPKGS)

EXTRA_DIST = *.vala
