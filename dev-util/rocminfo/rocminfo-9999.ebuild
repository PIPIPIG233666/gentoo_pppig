# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

if [[ ${PV} == *9999 ]] ; then
	EGIT_REPO_URI="https://github.com/RadeonOpenCompute/rocminfo/"
	inherit git-r3
else
	SRC_URI="https://github.com/RadeonOpenCompute/rocminfo/archive/rocm-${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/rocminfo-rocm-${PV}"
fi

DESCRIPTION="ROCm Application for Reporting System Info"
HOMEPAGE="https://github.com/RadeonOpenCompute/rocminfo"
LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"

RDEPEND="dev-libs/rocr-runtime"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=( -DROCRTST_BLD_TYPE=Release )
	cmake_src_configure
}
