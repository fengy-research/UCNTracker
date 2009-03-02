mkdir -p autotools
aclocal -I autotools
libtoolize --force --automake
autoheader
automake --add-missing
autoconf
./configure --enable-maintainer-mode $*
