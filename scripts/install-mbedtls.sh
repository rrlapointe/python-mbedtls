#!/bin/sh
# vim:noet:ts=2:sw=2:tw=79

set -ex

if [ "$(uname -s)" = "Linux" ]; then
	SED="sed -re"
else
	SED="sed -E"
fi


usage() {
	cat <<-EOF

	usage:
	  $0 SRCDIR [DESTDIR]

	Install a mbedtls from the sources in SRCDIR to DESTDIR.

	EOF
}


build_make() {
	$SED -i.bk "s (^DESTDIR=).* \\1$destdir g" Makefile

	CFLAGS="-DMBEDTLS_ARIA_C=ON" \
	SHARED="ON" \
	make -j lib
	make -j install
}


build_cmake() {
	mkdir build
	cd build
	cmake .. \
		-DCMAKE_INSTALL_PREFIX=$destdir \
		-DMBEDTLS_ARIS_C=ON \
		-DENABLE_TESTING=OFF \
		-DUSE_SHARED_MBEDTLS_LIBRARY=ON \
		-DUSE_STATIC_MBEDTLS_LIBRARY=OFF
	make -j lib
	make -j install
}


main() {
	if [ $# -lt 1 ]; then
		usage
		exit 1
	fi

	uname -s

	readonly srcdir="$1"
	local destdir="${2:-/usr/local}"
	case $destdir in
		/*) ;;
		*) destdir="$PWD/$destdir";;
	esac

	rm -rf $destdir

	cd $srcdir
	mkdir -p $destdir

	if [ -x "$(which cmakex)" ]; then
		build_cmake $destdir
	else
		build_make $destdir
	fi
}


main "$@"
