AC_INIT([UCNTracker], [0.0], [fengy@indiana.edu])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS(config.h)

AM_INIT_AUTOMAKE([tar-ustar foreign])

AM_MAINTAINER_MODE

AC_PROG_LIBTOOL
AC_PROG_CC
AM_PROG_CC_C_O
AC_PATH_PROGS(VALAC_BIN, [valac])
AC_SUBST(VALAC_FLAGS)
VALAC="$VALAC_BIN $VALAC_FLAGS --pkg gmodule-2.0"
AC_SUBST(VALAC)

AC_CHECK_LIB(m, log1p)
PKG_CHECK_MODULES(GLIB, [glib-2.0 >= 2.10 gobject-2.0 >= 2.10 gmodule-2.0 >= 2.10])
AC_SUBST(GLIB_CFLAGS)
AC_SUBST(GLIB_LIBS)

PKG_CHECK_MODULES(GSL, [gsl])
AC_SUBST(GSL_CFLAGS)
AC_SUBST(GSL_LIBS)

AC_CONFIG_FILES([
				Makefile
				ucntracker/Makefile
				ucntracker/builder/Makefile
				ucntracker/core/Makefile
				ucntracker/geometry/Makefile
				ucntracker/geometry/tests/Makefile
				ucntracker/device/Makefile
				ucntracker/device/tests/Makefile
				])

AC_OUTPUT
