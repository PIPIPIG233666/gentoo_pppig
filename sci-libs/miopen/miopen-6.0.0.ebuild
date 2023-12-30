# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake flag-o-matic llvm rocm

GTEST_COMMIT="e2239ee6043f73722e7aa812a459f54a28552929"
GTEST_FILE="gtest-1.11.0_p20210611.tar.gz"
KDB_FILE="gfx1030.kdb"

LLVM_MAX_SLOT=17

DESCRIPTION="AMD's Machine Intelligence Library"
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/MIOpen"

SRC_URI="https://github.com/ROCmSoftwarePlatform/MIOpen/archive/rocm-${PV}.tar.gz -> MIOpen-${PV}.tar.gz
	test? ( https://github.com/google/googletest/archive/${GTEST_COMMIT}.tar.gz -> ${GTEST_FILE} )
	https://github.com/PIPIPIG233666/gentoo_pppig/releases/download/${P}/gfx1030.kdb.bz2 -> ${KDB_FILE}.bz2
"

LICENSE="MIT"
KEYWORDS="~amd64"
SLOT="0/$(ver_cut 1-2)"

IUSE="debug test"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-util/hip
	dev-util/roctracer:${SLOT}[${ROCM_USEDEP}]
	>=dev-db/sqlite-3.17
	sci-libs/rocBLAS:${SLOT}[${ROCM_USEDEP}]
	sci-libs/composable-kernel:${SLOT}[${ROCM_USEDEP}]
	>=dev-libs/boost-1.72
	dev-cpp/nlohmann_json
	dev-cpp/frugally-deep
"

DEPEND="${RDEPEND}"

BDEPEND=">=dev-libs/half-6.0.0
	dev-util/rocm-cmake
"

S="${WORKDIR}/MIOpen-rocm-${PV}"

PATCHES=(
	"${FILESDIR}/${PN}-4.2.0-disable-no-inline-boost.patch"
	"${FILESDIR}/${PN}-4.2.0-gcc11-numeric_limits.patch"
	"${FILESDIR}/${PN}-4.3.0-fix-interface-include-in-HIP_COMPILER_FLAGS.patch"
	"${FILESDIR}/${PN}-4.3.0-enable-test.patch"
	"${FILESDIR}/${PN}-5.1.3-no-strip.patch"
	"${FILESDIR}/${PN}-5.1.3-include-array.patch"
)

src_prepare() {
	cp "${DISTDIR}/${KDB_FILE}.bz2" ${S}/src/kernels/ || die
	cmake_src_prepare

	sed -e "s:/opt/rocm/llvm:$(get_llvm_prefix ${LLVM_MAX_SLOT}) NO_DEFAULT_PATH:" \
		-e "s:/opt/rocm/hip:$(hipconfig -p) NO_DEFAULT_PATH:" \
		-e '/set( MIOPEN_INSTALL_DIR/s:miopen:${CMAKE_INSTALL_PREFIX}:' \
		-e '/MIOPEN_TIDY_ERRORS ALL/d' \
		-e 's:find_program(UNZIPPER lbunzip2 bunzip2):find_program(UNZIPPER NAMES lbunzip2 bunzip2):' \
		-i CMakeLists.txt || die

	sed -e "/add_test/s:--build \${CMAKE_CURRENT_BINARY_DIR}:--build ${BUILD_DIR}:" \
		-e "s,/opt/rocm,," \
		-e "s,MIOPEN_TEST_GFX103X,MIOPEN_TEST_GFX1030,g" \
		-i test/CMakeLists.txt || die

	sed -e "s:\${PROJECT_BINARY_DIR}/miopen/include:\${PROJECT_BINARY_DIR}/include:" \
		-i src/CMakeLists.txt || die

	sed -e "s:\${AMD_DEVICE_LIBS_PREFIX}/lib:${EPREFIX}/usr/lib/amdgcn/bitcode:" -i cmake/hip-config.cmake || die
}

src_configure() {
	if ! use debug; then
		append-cflags "-DNDEBUG"
		append-cxxflags "-DNDEBUG"
		CMAKE_BUILD_TYPE="Release"
	else
		CMAKE_BUILD_TYPE="Debug"
	fi

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DHALF_INCLUDE_DIR="${EPREFIX}/usr"
		-DMIOPEN_BACKEND=HIP
		-DBoost_USE_STATIC_LIBS=OFF
		-DMIOPEN_USE_MLIR=OFF
		-DBUILD_TESTS=$(usex test ON OFF)
		-DBUILD_FILE_REORG_BACKWARD_COMPATIBILITY=OFF
		-DROCM_SYMLINK_LIBS=OFF
	)

	if use test; then
		mycmakeargs+=(
			-DMIOPEN_TEST_ALL=ON
			-DBUILD_TESTING=ON
			-DMIOPEN_TEST_GDB=OFF
			-DGOOGLETEST_DIR="${WORKDIR}/googletest-${GTEST_COMMIT}"
		)
		for gpu_target in ${AMDGPU_TARGETS}; do
			mycmakeargs+=(-DMIOPEN_TEST_${gpu_target^^}=ON )
		done
	fi

	addpredict /dev/kfd
	addpredict /dev/dri/
	append-cxxflags "--rocm-path=$(hipconfig -R)"
	append-cxxflags "--hip-device-lib-path=${EPREFIX}/usr/lib/amdgcn/bitcode"
	CXX="$(get_llvm_prefix ${LLVM_MAX_SLOT})/bin/clang++" cmake_src_configure
}

src_test() {
	check_amdgpu
	export LD_LIBRARY_PATH="${BUILD_DIR}"/lib
	MAKEOPTS="-j1" cmake_src_test
}

src_install() {
	cmake_src_install
}
