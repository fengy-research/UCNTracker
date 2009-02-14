
noinst_PROGRAMS = test
test_VALASOURCES = test.vala
SUFFIXES = .vala .c
.vala.c:
	$(VALAC) -C ../builder.vapi $<

test_SOURCES = test.c test.h
test_CPPFLAGS = $(GLIB_CFLAGS) -I..
test_LDADD = $(GLIB_LIBS) ../libgtkbuilder.la
