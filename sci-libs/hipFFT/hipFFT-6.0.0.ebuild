# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm

DESCRIPTION="CU / ROCM agnostic hip FFT implementation"
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/hipFFT"
SRC_URI="https://github.com/ROCmSoftwarePlatform/hipFFT/archive/refs/tags/rocm-${PV}.tar.gz -> hipFFT-rocm-${PV}.tar.gz
https://github.com/ROCmSoftwarePlatform/rocFFT/archive/rocm-${PV}.tar.gz -> rocFFT-${PV}.tar.gz"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

LICENSE="MIT"
KEYWORDS="~amd64"
SLOT="0/$(ver_cut 1-2)"

RESTRICT="test"

RDEPEND="dev-util/hip:${SLOT}
	sci-libs/rocFFT:${SLOT}[${ROCM_USEDEP}]"
DEPEND="${RDEPEND}"
BDEPEND=""

S="${WORKDIR}/hipFFT-rocm-${PV}"

PATCHES=(
	"${FILESDIR}/${PN}-5.5.0-fix-include.patch"
)

src_prepare() {
	sed -e "/CMAKE_INSTALL_LIBDIR/d" -i CMakeLists.txt || die
	cmake_src_prepare
	rmdir clients/rocFFT || die
	mv -v ../rocFFT-rocm-${PV} clients/rocFFT || die
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_FILE_REORG_BACKWARD_COMPATIBILITY=OFF
		-DROCM_SYMLINK_LIBS=OFF
		-DCMAKE_MODULE_PATH="${EPREFIX}/usr/$(get_libdir)/cmake/hip"
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DHIP_ROOT_DIR="${EPREFIX}/usr"
		-DBUILD_CLIENTS_TESTS=OFF
		-DBUILD_CLIENTS_BENCH=OFF
	)

	ROCM_PATH="${EPREFIX}/usr" CXX=hipcc cmake_src_configure
}
