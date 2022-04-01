#!/bin/bash

get_sha256() {
	case $1 in
	-c)
		shift
		wget -q $1 -O - | grep $2 | awk '{print $1}'
	;;
	-l)
		shift
		[ ! -f "$1" ] && return 1
		sha256sum $1 2> /dev/null | awk '{print $1}'
	;;
	esac
}

_exit() {
	exit_singal=$1
	shift
	echo $*
	exit $exit_singal
}

RELEASE="20.04.4"
ARCH="armhf"
IMG_FILE="ubuntu-base-${RELEASE}-base-${ARCH}.tar.gz"
IMG_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/${RELEASE}/release"

mkdir -p downloads && cd downloads

if [ "$(get_sha256 -c ${IMG_URL}/SHA256SUMS ${IMG_FILE})" != "$(get_sha256 -l ${IMG_FILE})" ]
then
	wget --no-check-certificate ${IMG_URL}/${IMG_FILE} || _exit 1 "Failed to download ${IMG_FILE} ..."
fi

cd -
if [ ! -d rootfs ]
then
	mkdir -p rootfs
elif [ "$(ls -A rootfs)" ]
then
	rm -rf rootfs/*
fi
tar -zxvf downloads/${IMG_FILE} -C rootfs
echo -e "$RELEASE\n$ARCH" > target_arch
