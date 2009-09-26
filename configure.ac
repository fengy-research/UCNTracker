AC_INIT([UCNTracker], [0.1], [fengy@indiana.edu])

AC_CONFIG_MACRO_DIR([autotools])
AC_CONFIG_AUX_DIR([autotools])
AC_SUBST(ACLOCAL_AMFLAGS, "-I autotools")

AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS(config.h)

AM_INIT_AUTOMAKE([tar-ustar foreign subdir-objects])
depdir='$(top_srcdir)/dependency'
AC_SUBST(depdir)
AM_MAINTAINER_MODE
AC_PROG_LIBTOOL
DOLT
AC_PROG_CC
AM_PROG_CC_C_O
CFLAGS="$CFLAGS -std=c99"
VALA_PROG_VALAC(0.5.7)
VALA_PROG_VALADOC()
VALA_VAPI_DIRS(['$(top_srcdir)/vapi' '$(top_srcdir)/ucntracker' '$(top_srcdir)/ucntracker-vis'])

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

WITH_INSTALLED([libyaml-glib], use_installed_libyaml_glib)

if test "x$use_installed_YAMLGLIB" == xyes; then
	PKG_CHECK_MODULES(YAML, [libyaml-glib >= 0.1])
	YAML_VALAFLAGS=
else
	AC_CONFIG_SUBDIRS(dependency/libyaml-glib)
	YAML_CFLAGS="-I$depdir/libyaml-glib/src -I$depdir/libyaml-glib/libyaml/include"
	YAML_LIBS="$depdir/libyaml-glib/src/libyaml-glib.la"
	YAML_VALAFLAGS="--vapidir=$depdir/libyaml-glib/src"
fi;
AC_SUBST(YAML_CFLAGS)
AC_SUBST(YAML_LIBS)
AC_SUBST(YAML_VALAFLAGS)
AM_CONDITIONAL(USE_INSTALLED_LIBYAML_GLIB, [ test x$use_installed_libyaml_glib = xyes ])


#AC_SUBST(ENDF_CFLAGS)
#AC_SUBST(ENDF_LIBS)
#CHECK_MODULE(ENDF, libendf, libendf-1.0, 0.1)
#if test "x$use_builtin_ENDF" == xyes; then
#AC_CONFIG_SUBDIRS(libendf)
#ENDF_CFLAGS='-I$(top_srcdir)/libendf/src'
#ENDF_LIBS='-L$(top_builddir)/libendf/src -lendf'
#fi
#AC_SUBST(ENDF_CFLAGS)
#AC_SUBST(ENDF_LIBS)


AC_CONFIG_FILES([
				Makefile
				dependency/Makefile
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
				tools/Makefile
				])

AC_OUTPUT
