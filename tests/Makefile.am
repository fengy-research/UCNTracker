include ../Makefile.vars

nonvis_test = test-rng test-builder test-qua
vis_test = test-gtk

test_gtk_CPPFLAGS = $(VIS_PROGRAM_CFLAGS)
test_gtk_LDADD = $(VIS_PROGRAM_LIBS)

test_rng_CPPFLAGS = $(NONVIS_PROGRAM_CFLAGS)
test_rng_LDADD = $(NONVIS_PROGRAM_LIBS)

test_mcrng_LDADD = $(NONVIS_PROGRAM_LIBS)
test_mcrng_CPPFLAGS = $(NONVIS_PROGRAM_CFLAGS)

test_builder_LDADD = $(NONVIS_PROGRAM_LIBS)
test_builder_CPPFLAGS = $(NONVIS_PROGRAM_CFLAGS)

test_qua_LDADD = $(NONVIS_PROGRAM_LIBS)
test_qua_CPPFLAGS = $(NONVIS_PROGRAM_CFLAGS)

AM_LDFLAGS = -export-dynamic -rdynamic

VALAFLAGS = --vapidir=../ucntracker --vapidir=../ucntracker-vis $(YAML_VALAFLAGS)
VALAPKGS = --pkg ucntracker-vis-1.0

noinst_PROGRAMS = $(vis_test) $(nonvis_test)
SUFFIXES = .vala .c

.vala.c :
	$(VALAC) $(VALAFLAGS) -C $^ $(VALAPKGS)
	touch $@


BUILT_SOURCES = $(noinst_PROGRAMS:=.c)

EXTRA_DIST = $(noinst_PROGRAMS:=.vala)

check-local:
	for i in $(noinst_PROGRAMS); do \
		./$$i; \
    done;

