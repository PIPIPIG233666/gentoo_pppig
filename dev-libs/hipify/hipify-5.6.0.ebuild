# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Convert CUDA to Portable C++ Code"
HOMEPAGE="https://github.com/ROCm-Developer-Tools/HIPIFY"
S="${WORKDIR}/${PN^^}-rocm-${PV}"
SRC_URI="https://github.com/ROCm-Developer-Tools/HIPIFY/archive/rocm-${PV}.tar.gz -> ${P^^}.tar.gz"
KEYWORDS="~amd64"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
RESTRICT="test"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

PATCHES=( "${FILESDIR}/hipify-9999-llvm-link.patch" )

# src_prepare() {
	# sed -e 's,"@FILE_REORG_BACKWARD_COMPATIBILITY@",OFF,g' -i packaging/hipify-clang.txt || die
# }

src_configure() {
	addpredict /dev/kfd
	addpredict /dev/dri/

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DFILE_REORG_BACKWARD_COMPATIBILITY=OFF
	)
	cmake_src_configure
}

src_install() {
	cd "${S}" || die
	dobin bin/hipify-perl
	cd "${BUILD_DIR}" || die
	dobin hipify-clang
}
