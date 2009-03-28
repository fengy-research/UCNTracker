lib_LTLIBRARIES = libvalartl-yaml.la
VALASOURCES = yaml.vala

libvalartl_yaml_la_SOURCES = $(VALASOURCES:.vala=.c) $(VALASOURCES:.vala=.h)
libvalartl_yaml_la_LIBADD = $(GLIB_LIBS)
libvalartl_yaml_la_CPPFLAGS = $(GLIB_CFLAGS)
libvalartl_yaml_la_LDFLAGS = -g

BUILT_SOURCES = vala-ccode
VALAFLAGS= --library=valartl-yaml --basedir=$(top_srcdir)

@VALA_CCODE_RULES@

EXTRA_DIST = $(VALASOURCES) vala-ccode valartl-yaml.vapi
rtlyamlinclude_HEADERS = $(VALASOURCES:.vala=.h)
rtlyamlincludedir = $(includedir)/vala-rtl/yaml

noinst_PROGRAMS = test
test_SOURCES = test.vala
test_LDADD = libvalartl-yaml.la
.vala.o:
	$(VALAC) --save-temps -c ./valartl-yaml.vapi $< -X -I$(top_srcdir) -X -g
