mkdir -p autotools
aclocal -I autotools
libtoolize --force --automake
autoheader
automake --add-missing
autoconf
(cd libyaml-glib; ./autogen.sh --no-configure $*;)
(cd libendf; ./autogen.sh --no-configure $*;)
./configure --enable-maintainer-mode $*

