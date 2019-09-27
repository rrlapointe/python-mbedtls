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


make_destdir() {
	rm -rf $destdir
	mkdir -p $destdir
}


enter_make() {
	rm -rf $builddir
	cp -R $srcdir $builddir
	cd $builddir
}


exit_make() {
	echo -n
}


build_make() {
	$SED -i.bk "s (^DESTDIR=).* \\1$destdir g" Makefile

	CFLAGS="-DMBEDTLS_ARIA_C=ON" \
	SHARED="ON" \
	make -j lib
	make -j install
}


main() {
	if [ $# -lt 1 ]; then
		usage
		exit 1
	fi

	readonly srcdir="$1"
	readonly builddir="$srcdir/../.build"

	local destdir="${2:-/usr/local}"
	case $destdir in
		/*) ;;
		*) destdir="$PWD/$destdir";;
	esac

	enter_make
	build_make || true
	exit_make
}


main "$@"
