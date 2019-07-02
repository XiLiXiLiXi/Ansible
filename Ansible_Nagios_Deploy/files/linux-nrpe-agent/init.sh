#!/bin/bash -e

xivar() {
	./xivar "$1" "$2"
	eval "$1"=\"\$2\"
}

# OS-related variables have a detailed long variable, and a more useful short
# one: distro/dist, version/ver, architecture/arch. If in doubt, use the short
. ./get-os-info
xivar distro  "$distro"
xivar version "$version"
xivar ver     "${version%%.*}" # short major version, e.g. "6" instead of "6.2"
xivar architecture "$architecture"

# Set dist variable like before (el5/el6 on both CentOS & Red Hat)
case "$distro" in
	CentOS | RedHatEnterpriseServer )
		xivar dist "el$ver"
		;;
	EnterpriseEnterpriseServer | OracleServer )
		xivar dist "oracle$ver"
		;;
    Debian )
		xivar dist "debian$ver"
		;;
	CloudLinux )
	    xivar dist "el$ver"
		;;
	"Amazon Linux AMI" )
        xivar distro CentOS
        xivar version "6"
        xivar dist "el$ver"
        ;;
    *)
		xivar dist $(echo "$distro$version" | tr A-Z a-z)
esac

# i386 is a more useful value than i686 for el5, because repo paths and
# package names use i386
if [ "$dist $architecture" = "el5 i686" ]; then
	xivar arch i386
else
	xivar arch "$architecture"
fi

case "$dist" in
	el5 | el6 | oracle6)
		if [ "$arch" = "x86_64" ]; then
			xivar php_extension_dir /usr/lib64/php/modules
		fi
		;;
	*)
		:
esac

