noinst_LTLIBRARIES = libvalartl.la
VALASOURCES = buildable.vala builder.vala yaml.vala

libvalartl_la_SOURCES = $(VALASOURCES:.vala=.c) valartl.h \
	value_from_string.c
libvalartl_la_LIBADD = $(GLIB_LIBS)
libvalartl_la_CPPFLAGS = $(GLIB_CFLAGS)
libvalartl_la_LDFLAGS = -g 

BUILT_SOURCES = vala-ccode
VALAFLAGS= --library=valartl --basedir=$(top_srcdir) -H valartl.h
VALADOCFLAGS = --package-name=valartl -o Documentation
VALAPKGS = --pkg gmodule-2.0
@VALA_CCODE_RULES@
if ENABLE_VALADOC
@VALA_DOC_RULES@
BUILT_SOURCES += vala-doc
endif

EXTRA_DIST = $(VALASOURCES) vala-ccode valartl.vapi
rtlinclude_HEADERS = valartl.h
rtlincludedir = $(includedir)/ucntracker

noinst_PROGRAMS = test
test_SOURCES = test.vala
test_LDADD = libvalartl.la
test_LDFLAGS = -export-dynamic
.vala.o:
	$(VALAC) -c $(srcdir)/valartl.vapi $< -X -I$(srcdir) -X -I. -X -g
	mv $(@:.o=.vala.o) $@
