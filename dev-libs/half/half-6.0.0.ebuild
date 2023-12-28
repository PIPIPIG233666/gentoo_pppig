# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake

DESCRIPTION="Half-precision floating-point library"
HOMEPAGE="http://half.sourceforge.net/"
SRC_URI="https://github.com/ROCm/half/archive/rocm-${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/half-rocm-${PV}"

LICENSE="MIT"
KEYWORDS="~amd64"
SLOT="0/$(ver_cut 1)"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_INCLUDEDIR="${EPREFIX}/usr"
	)
	cmake_src_configure
}

