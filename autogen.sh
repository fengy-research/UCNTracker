mkdir -p autotools
aclocal -I autotools
libtoolize --force --automake
autoheader
automake --add-missing
autoconf
(cd libyaml; autoreconf -fvi;)
./configure --enable-maintainer-mode $*

