
noinst_PROGRAMS = test
test_VALASOURCES = test.vala
SUFFIXES = .vala .c
.vala.c:
	$(VALAC) -C ../builder.vapi $<

test_SOURCES = test.c test.h
test_CPPFLAGS = $(GLIB_CFLAGS) -I$(top_srcdir)/gtkbuilder
test_LDADD = $(GLIB_LIBS) ../libgtkbuilder.la
