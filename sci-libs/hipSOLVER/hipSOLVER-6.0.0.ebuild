# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake edo rocm

DESCRIPTION="Implementation of a subset of LAPACK functionality on the ROCm platform"
HOMEPAGE="https://github.com/ROCm/hipSOLVER"
SRC_URI="https://github.com/ROCm/hipSOLVER/archive/rocm-${PV}.tar.gz -> hipSOLVER-${PV}.tar.gz"
S="${WORKDIR}/${PN}-rocm-${PV}"
KEYWORDS="~amd64"

LICENSE="BSD"
SLOT="0/$(ver_cut 1-2)"

IUSE="test benchmark"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

RDEPEND="dev-util/hip
	sci-libs/rocBLAS:${SLOT}[${ROCM_USEDEP}]
	dev-libs/libfmt
	benchmark? ( virtual/blas )"
DEPEND="${RDEPEND}"
BDEPEND="test? ( dev-cpp/gtest
	>=dev-util/cmake-3.22
	virtual/blas )"

RESTRICT="!test? ( test )"

src_prepare() {
	# do not install test binary
	sed '/rocm_install(/ {:r;/)/!{N;br}; s,.*,,}' -i clients/gtest/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	# avoid sandbox violation
	addpredict /dev/kfd
	addpredict /dev/dri/

	local mycmakeargs=(
		-DBUILD_FILE_REORG_BACKWARD_COMPATIBILITY=OFF
		-DROCM_SYMLINK_LIBS=OFF
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-Wno-dev
		-DBUILD_CLIENTS_SAMPLES=NO
		-DBUILD_CLIENTS_TESTS=OFF
		-DBUILD_CLIENTS_BENCHMARKS=$(usex benchmark ON OFF)
	)

	CXX=hipcc cmake_src_configure
}

