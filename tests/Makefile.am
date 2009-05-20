vis_test = test-rng test-mcrng test-builder
nonvis_test = test-gtk

test_gtk_CPPFLAGS = $(VIS_PROGRAM_CFLAGS)
test_gtk_LDADD = $(VIS_PROGRAM_LIBS)

test_rng_CPPFLAGS = $(NONVIS_PROGRAM_CFLAGS)
test_rng_LDADD = $(NONVIS_PROGRAM_LIBS)

test_mcrng_LDADD = $(NONVIS_PROGRAM_LIBS)
test_mcrng_CPPFLAGS = $(NONVIS_PROGRAM_CFLAGS)

test_builder_LDADD = $(NONVIS_PROGRAM_LIBS)
test_builder_CPPFLAGS = $(NONVIS_PROGRAM_CFLAGS)
AM_LDFLAGS = -export-dynamic -rdynamic

VALAPKGS = --pkg ucntracker-vis

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

