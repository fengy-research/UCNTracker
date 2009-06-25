AC_INIT([UCNTracker], [0.1], [fengy@indiana.edu])

AC_CONFIG_MACRO_DIR([autotools])
AC_CONFIG_AUX_DIR([autotools])
AC_SUBST(ACLOCAL_AMFLAGS, "-I autotools")

AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS(config.h)

AM_INIT_AUTOMAKE([tar-ustar foreign subdir-objects])

AM_MAINTAINER_MODE
AC_PROG_LIBTOOL
DOLT
AC_PROG_CC
AM_PROG_CC_C_O
CFLAGS="$CFLAGS -std=c99"
VALA_PROG_VALAC(0.5.7)
VALA_PROG_VALADOC()
VALA_VAPI_DIRS(['$(top_srcdir)/vapi' '$(top_srcdir)/libendf/src' '$(top_srcdir)/libyaml-glib/src' '$(top_srcdir)/ucntracker' '$(top_srcdir)/ucntracker-vis'])

AC_CHECK_LIB(m, log1p)
PKG_CHECK_MODULES(GLIB, [glib-2.0 >= 2.10 gobject-2.0 >= 2.10 gmodule-2.0 >= 2.10])
AC_SUBST(GLIB_CFLAGS)
AC_SUBST(GLIB_LIBS)

PKG_CHECK_MODULES(GTK, [gtk+-2.0 >= 2.10])
AC_SUBST(GTK_CFLAGS)
AC_SUBST(GTK_LIBS)

PKG_CHECK_MODULES(GTKGL, [gtkglext-1.0 >= 1.0])
AC_SUBST(GTKGL_CFLAGS)
AC_SUBST(GTKGL_LIBS)

PKG_CHECK_MODULES(GSL, [gsl])
AC_SUBST(GSL_CFLAGS)
AC_SUBST(GSL_LIBS)

AC_DEFUN([CHECK_MODULE], [
	AC_ARG_WITH(with_builtin_$1,
		[AS_HELP_STRING([--with-builtin-$2=check], [use the builtin $2]) ],
		[],
		[with_builtin_$1=check]
	)

	if test "x$with_builtin_$1" != xyes; then
		PKG_CHECK_MODULES($1, [$3 >= $4],
		[ 
			AC_MSG_WARN([linking against $2 installed in the system]) 
			with_builtin_$1=no;
		], [
			if test "x$with_builtin_$1" != xcheck; then
				AC_MSG_FAILURE([$2 not found in the system.])
			fi
		])
	fi
	if test "x$with_builtin_$1" != xno; then
		AC_MSG_WARN([building $2 as a subpackage]);
		use_builtin_$1=yes;
	fi
	AM_CONDITIONAL(USE_BUILTIN_$1, [test x$use_builtin_$1 == xyes])
])

PKG_CHECK_MODULES(YAMLGLIB, libyaml-glib-1.0 >= 0.1)
AC_SUBST(YAMLGLIB_CFLAGS)
AC_SUBST(YAMLGLIB_LIBS)

CHECK_MODULE(ENDF, libendf, libendf-1.0, 0.1)
if test "x$use_builtin_ENDF" == xyes; then
AC_CONFIG_SUBDIRS(libendf)
ENDF_CFLAGS='-I$(top_srcdir)/libendf/src'
ENDF_LIBS='-L$(top_builddir)/libendf/src -lendf'
fi
AC_SUBST(ENDF_CFLAGS)
AC_SUBST(ENDF_LIBS)

UCNTRACKER_CFLAGS='-I$(top_srcdir)/ucntracker'
UCNTRACKER_LIBS='-L$(top_builddir)/ucntracker -lucntracker'
AC_SUBST(UCNTRACKER_CFLAGS)
AC_SUBST(UCNTRACKER_LIBS)

UCNTRACKER_VIS_CFLAGS='-I$(top_srcdir)/ucntracker-vis'
UCNTRACKER_VIS_LIBS='-L$(top_builddir)/ucntracker-vis -lucntracker-vis'
AC_SUBST(UCNTRACKER_VIS_CFLAGS)
AC_SUBST(UCNTRACKER_VIS_LIBS)

NONVIS_PROGRAM_CFLAGS='$(GLIB_CFLAGS) $(GSL_CFLAGS) $(YAMLGLIB_CFLAGS) $(ENDF_CFLAGS) $(UCNTRACKER_CFLAGS)'
NONVIS_PROGRAM_LIBS='$(GLIB_LIBS) $(GSL_LIBS) $(YAMLGLIB_LIBS) $(ENDF_LIBS) $(UCNTRACKER_LIBS)'
AC_SUBST(NONVIS_PROGRAM_CFLAGS)
AC_SUBST(NONVIS_PROGRAM_LIBS)

VIS_PROGRAM_CFLAGS='$(NONVIS_PROGRAM_CFLAGS) $(GTK_CFLAGS) $(GTKGL_CFLAGS) $(UCNTRACKER_VIS_CFLAGS)'
VIS_PROGRAM_LIBS='$(NONVIS_PROGRAM_LIBS) $(GTK_LIBS) $(GTKGL_LIBS) $(UCNTRACKER_VIS_LIBS)'
AC_SUBST(VIS_PROGRAM_CFLAGS)
AC_SUBST(VIS_PROGRAM_LIBS)


AC_CONFIG_FILES([
				Makefile
				ucntracker/Makefile
				ucntracker/ucntracker-1.0.pc
				ucntracker-vis/Makefile
				ucntracker-vis/ucntracker-vis-1.0.pc
				tests/Makefile
				vapi/Makefile
				examples/Makefile
				examples/E01/Makefile
				examples/E02/Makefile
				examples/E03/Makefile
				examples/Mirror/Makefile
				examples/NonUniformedMagField/Makefile
				tools/Makefile
				])

AC_OUTPUT
