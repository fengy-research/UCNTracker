AC_INIT([UCNTracker], [0.0], [fengy@indiana.edu])

AC_CONFIG_MACRO_DIR([autotools])
AC_CONFIG_AUX_DIR([autotools])
AC_SUBST(ACLOCAL_AMFLAGS, "-I autotools")

AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS(config.h)

AM_INIT_AUTOMAKE([tar-ustar foreign])

AM_MAINTAINER_MODE
AC_PROG_LIBTOOL
DOLT
AC_PROG_CC
AM_PROG_CC_C_O
VALA_PROG_VALAC(0.5.6)
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

AC_CONFIG_FILES([
				Makefile
				ucntracker/Makefile
				ucntracker/tests/Makefile
				ucntracker/vis-tests/Makefile
				ucntracker/builder/Makefile
				ucntracker/math/Makefile
				ucntracker/physics/Makefile
				ucntracker/core/Makefile
				ucntracker/library/Makefile
				ucntracker/visualize/Makefile
				examples/Makefile
				examples/E01/Makefile
				])

AC_OUTPUT
