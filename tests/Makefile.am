ucntracker_test = test-rng.vala test-mcrng.vala test-builder.vala
ucntracker_vis_test = test-gtk.vala

test_gtk_CPPFLAGS = $(ucntracker_vis_test_CPPFLAGS)
test_gtk_LDADD = $(ucntracker_vis_test_LDADD)

test_rng_CPPFLAGS = $(ucntracker_test_CPPFLAGS)
test_rng_LDADD = $(ucntracker_test_LDADD)

test_mcrng_LDADD = $(ucntracker_test_LDADD)
test_mcrng_CPPFLAGS = $(ucntracker_test_CPPFLAGS)

test_builder_LDADD = $(ucntracker_test_LDADD)
test_builder_CPPFLAGS = $(ucntracker_test_CPPFLAGS)
AM_LDFLAGS = -export-dynamic -rdynamic


VALAFLAGS = --vapidir=../vapi \
	--vapidir=../ucntracker \
	--vapidir=../ucntracker-vis

VALAPKGS = --pkg ucntracker-vis

ucntracker_vis_test_CPPFLAGS = $(GTK_CFLAGS) \
		$(GTKGL_CFLAGS) \
		-I../ucntracker \
		-I../ucntracker-vis
ucntracker_vis_test_LDADD = ../ucntracker-vis/libucntracker-vis.la \
 ../ucntracker/libucntracker.la 

ucntracker_test_CPPFLAGS = $(GLIB_CFLAGS) \
		-I../ucntracker
ucntracker_test_LDADD = ../ucntracker/libucntracker.la 

noinst_PROGRAMS = $(ucntracker_test:.vala=) $(ucntracker_vis_test:.vala=)

ucntracker-test-ccode: $(ucntracker_test)
	for f in $^; do \
	$(VALAC) $(VALAFLAGS) -C $$f $(VALAPKGS) || exit 1; \
	done;
	touch $@
ucntracker-vis-test-ccode: $(ucntracker_vis_test)
	for f in $^; do \
	$(VALAC) $(VALAFLAGS) -C $$f $(VALAPKGS) || exit 1; \
	done;
	touch $@

BUILT_SOURCES = ucntracker-test-ccode ucntracker-vis-test-ccode
EXTRA_DIST = $(ucntracker_vis_test) $(ucntracker_test) $(BUILT_SOURCES)

check-local:
	for i in $(noinst_PROGRAMS); do \
		./$$i; \
    done;
