
VALAPKGS = --pkg ucntracker
VALAFLAGS = --vapidir=../ucntracker
LDADD = ../ucntracker/libucntracker.la
AM_CPPFLAGS = $(GLIB_CFLAGS) -I ../ucntracker -I ../valartl
noinst_PROGRAMS = sample-volume
sample_volume_SOURCES = sample-volume.c

SUFFIXES = .vala .c

.vala.c:
	$(VALAC) -C $(VALAFLAGS) $< $(VALAPKGS)

EXTRA_DIST = *.vala
