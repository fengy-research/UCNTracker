dnl Autoconf scripts for the Vala compiler
dnl Copyright (C) 2007  Mathias Hasselmann
dnl
dnl This library is free software; you can redistribute it and/or
dnl modify it under the terms of the GNU Lesser General Public
dnl License as published by the Free Software Foundation; either
dnl version 2 of the License, or (at your option) any later version.

dnl This library is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
dnl Lesser General Public License for more details.

dnl You should have received a copy of the GNU Lesser General Public
dnl License along with this library; if not, write to the Free Software
dnl Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
dnl
dnl Author:
dnl 	Yu Feng
dnl --------------------------------------------------------------------------

dnl VALA_PROG_VALADOC([MINIMUM-VERSION])
dnl
dnl Check whether the Vala compiler exists in `PATH'. If it is found the
dnl variable VALAC is set. Optionally a minimum release number of the compiler
dnl can be requested.
dnl --------------------------------------------------------------------------
AC_DEFUN([VALA_PROG_VALADOC],[
  enable_valadoc=yes
  AC_ARG_ENABLE(
    [valadoc],
    AC_HELP_STRING([--enable-valadoc], [default is yes]),
    [ test "x$enableval" == xno && enable_valadoc=yes ],
    [ enable_valadoc=yes ])

  AS_IF([test "x$enable_valadoc" == xyes ],
    [ AC_PATH_PROG([VALADOC_BIN], [valadoc], [])
      AS_IF([ test -z "${VALADOC_BIN}" ],
        AC_MSG_WARN([No valadoc found. You will not be able to generate document files.]) 
        enable_valadoc=no
      )
    ])

  AM_CONDITIONAL(ENABLE_VALADOC, [ test "x$enable_valadoc" == xyes ])

  AC_SUBST(VALADOC_BIN)
  VALADOC="$VALADOC_BIN --force --vapidir=\$(top_srcdir)/vapi"
  AC_SUBST(VALADOC)
  VALA_DOC_RULES='vala-doc: $(VALASOURCES); $(VALADOC) $(VALADOCFLAGS) $^ $(VALAPKGS) && touch vala-doc'

  AC_SUBST(VALA_DOC_RULES)

])
