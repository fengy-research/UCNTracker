SUBDIRS = . tests
lib_LTLIBRARIES = libgtkbuilder.la

libgtkbuilder_la_SOURCES =  \
gtkbuildable.h \
gtkbuilder.h \
gtkbuilderprivate.h \
gtkbuildable.c \
gtkbuilder.c \
gtkbuilderparser.c \
nls.h

libgtkbuilder_la_LDFLAGS = -no-undefined
libgtkbuilder_la_LIBADD = $(GLIB_LIBS)
libgtkbuilder_la_CPPFLAGS = $(GLIB_CFLAGS)
