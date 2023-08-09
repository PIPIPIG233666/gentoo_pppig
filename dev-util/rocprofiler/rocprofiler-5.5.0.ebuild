# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
ROCM_VERSION=${PV}

inherit cmake edo llvm python-any-r1 rocm

LLVM_MAX_SLOT=16

DESCRIPTION="Callback/Activity Library for Performance tracing AMD GPU's"
HOMEPAGE="https://github.com/ROCm-Developer-Tools/rocprofiler.git"
SRC_URI="https://github.com/ROCm-Developer-Tools/${PN}/archive/rocm-${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-rocm-${PV}"
KEYWORDS="~amd64"

LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"
IUSE="test"
RESTRICT="!test? ( test )"
REQUIRED_USE="test? ( ${ROCM_REQUIRED_USE} )"

RDEPEND=">=dev-libs/rocr-runtime-5.4.3
	dev-util/roctracer:${SLOT}
	"
DEPEND="${RDEPEND}"
BDEPEND="
	$(python_gen_any_dep '
	dev-python/CppHeaderParser[${PYTHON_USEDEP}]
	dev-python/barectf[${PYTHON_USEDEP}]
	')
"

PATCHES=(
	"${FILESDIR}/${PN}-4.3.0-no-aqlprofile.patch"
	# "${FILESDIR}/${PN}-5.3.3-gentoo-location.patch"
	"${FILESDIR}/${PN}-5.4.3-test-fix-build-kernel.patch"
	"${FILESDIR}/${PN}-5.4.3-disable-tests-who-need-aqlprofile.patch"
	"${FILESDIR}/${PN}-5.5.0-remove-aql-in-cmake.patch"
	"${FILESDIR}/${PN}-5.5.0-gcc-13-fix.patch"
)

python_check_deps() {
	python_has_version "dev-python/CppHeaderParser[${PYTHON_USEDEP}]"
}

src_prepare() {
	cmake_src_prepare

	sed -e "s,@LIB_DIR@,$(get_libdir),g" -i bin/rpl_run.sh || die
	sed -e "s,@BC_DIR@,${EPREFIX}/usr/lib/amdgcn/bitcode,g" -i bin/build_kernel.sh || die
	local LLVM_PREFIX="$(get_llvm_prefix "${LLVM_MAX_SLOT}")"
	sed -e "s,@LLVM_DIR@,${LLVM_PREFIX},g" -i bin/build_kernel.sh || die
	local CLANG_RESOURCE_DIR=$("${LLVM_PREFIX}/bin/clang" -print-resource-dir)
	sed -e "s,@CLANG_DIR@,${CLANG_RESOURCE_DIR},g" -i bin/build_kernel.sh || die
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=On
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DCMAKE_PREFIX_PATH="${EPREFIX}/usr/include/hsa"
		-DCMAKE_MODULE_PATH="${EPREFIX}/usr/$(get_libdir)/cmake/hip"
		-DPROF_API_HEADER_PATH="${EPREFIX}"/usr/include/roctracer/ext
		-DFILE_REORG_BACKWARD_COMPATIBILITY=OFF
		-DUSE_PROF_API=1
		-DHIP_ROOT_DIR="${EPREFIX}/usr"
	)

	use test && mycmakeargs+=( -DGPU_TARGETS="${AMDGPU_TARGETS}" )

	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	if use test; then
		cmake_build mytest
		cp -av "${S}"/test/run.sh "${BUILD_DIR}"/ || die
	fi
}

src_test() {
	check_amdgpu
	ewarn "Most of tests are disabled due to stripping the proprietary"
	ewarn "libhsa-amd-aqlprofile.so."
	cd "${BUILD_DIR}" || die
	edo ./run.sh
}

pkg_postinst() {
	ewarn "Gentoo currently does not ship proprietary libhsa-amd-aqlprofile.so."
	ewarn "HSA runtime and profiler are stripped off this dependency."
	ewarn "This may cause some profiler/tracing function missing."
	ewarn "See https://bugs.gentoo.org/716948"
}
