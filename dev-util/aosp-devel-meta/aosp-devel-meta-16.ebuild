# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Meta package providing AOSP build environment"
HOMEPAGE="https://source.android.com/source/initializing"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

RDEPEND="
	app-arch/libarchive[static-libs]
	app-arch/unzip
	app-arch/zip
	app-crypt/gnupg
	dev-libs/libxml2
	dev-libs/libxslt
	dev-perl/Switch
	dev-util/android-tools
	dev-util/ccache
	dev-util/gperf
	dev-vcs/git
	dev-vcs/repo
	media-fonts/noto
	media-libs/libsdl
	media-libs/mesa
	net-misc/curl
	net-misc/inetutils
	net-misc/rsync
	sys-devel/bc
	sys-devel/bison
	sys-devel/flex
	sys-devel/gcc[cxx]
	sys-fs/squashfs-tools
	sys-libs/libxcrypt-compat
	sys-libs/ncurses-compat:5=[abi_x86_32,tinfo]
	sys-libs/readline[abi_x86_32]
	sys-libs/zlib
	sys-libs/zlib[abi_x86_32]
	sys-process/schedtool
"
	# x11-base/xorg-proto
	# x11-libs/libX11
	# x11-libs/wxGTK:3.0
