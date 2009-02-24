aclocal
libtoolize --force
autoconf --force
autoheader --force
automake --add-missing
./configure --enable-maintainer-mode $*
