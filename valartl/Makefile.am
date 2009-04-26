noinst_LTLIBRARIES = libvalartl.la
VALASOURCES = buildable.vala builder.vala yaml.vala

libvalartl_la_SOURCES = $(VALASOURCES:.vala=.c) $(VALASOURCES:.vala=.h) \
	value_from_string.c
libvalartl_la_LIBADD = $(GLIB_LIBS)
libvalartl_la_CPPFLAGS = $(GLIB_CFLAGS)
libvalartl_la_LDFLAGS = -g 

BUILT_SOURCES = vala-ccode
VALAFLAGS= --library=valartl --basedir=$(top_srcdir)
VALADOCFLAGS = --package-name=valartl -o Documentation
VALAPKGS = --pkg gmodule-2.0
@VALA_CCODE_RULES@
if ENABLE_VALADOC
@VALA_DOC_RULES@
BUILT_SOURCES += vala-doc
endif

EXTRA_DIST = $(VALASOURCES) vala-ccode valartl.vapi
rtlinclude_HEADERS = $(VALASOURCES:.vala=.h)
rtlincludedir = $(includedir)/vala-rtl

noinst_PROGRAMS = test
test_SOURCES = test.vala
test_LDADD = libvalartl.la
test_LDFLAGS = -export-dynamic
.vala.o:
	$(VALAC) -c ./valartl.vapi $< -X -I$(top_srcdir) -X -g
