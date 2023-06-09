# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..12} )
ROCM_VERSION=5.5.0
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1
inherit distutils-r1 rocm

DESCRIPTION="Tensors and Dynamic neural networks in Python"
HOMEPAGE="https://pytorch.org/"
SRC_URI="https://github.com/pytorch/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="rocm"
RESTRICT="test"

REQUIRED_USE="
${PYTHON_REQUIRED_USE}
rocm? ( ${ROCM_REQUIRED_USE} )
"
RDEPEND="
	${PYTHON_DEPS}
	~sci-libs/caffe2-${PV}[${PYTHON_SINGLE_USEDEP}]
	rocm? (
		dev-util/hip
		dev-util/roctracer
		dev-libs/rccl[${ROCM_USEDEP}]
		sci-libs/hipFFT[${ROCM_USEDEP}]
		sci-libs/hipSPARSE[${ROCM_USEDEP}]
		sci-libs/hipCUB[${ROCM_USEDEP}]
		sci-libs/miopen[${ROCM_USEDEP}]
		sci-libs/rocBLAS[${ROCM_USEDEP}]
		sci-libs/rocFFT[${ROCM_USEDEP}]
		sci-libs/rocPRIM[${ROCM_USEDEP}]
		sci-libs/rocRAND[${ROCM_USEDEP}]
		sci-libs/rocThrust[${ROCM_USEDEP}]
	)
	$(python_gen_cond_dep '
		dev-python/typing-extensions[${PYTHON_USEDEP}]
		dev-python/sympy[${PYTHON_USEDEP}]
	')
"
DEPEND="${RDEPEND}
	$(python_gen_cond_dep '
		dev-python/pyyaml[${PYTHON_USEDEP}]
	')
"

src_prepare() {
	eapply \
		"${FILESDIR}"/0002-Don-t-build-libtorch-again-for-PyTorch-1.7.1.patch \
		"${FILESDIR}"/pytorch-1.9.0-Change-library-directory-according-to-CMake-build.patch \
		"${FILESDIR}"/${PN}-2.0.0-global-dlopen.patch \
		"${FILESDIR}"/pytorch-1.7.1-torch_shm_manager.patch \
		"${FILESDIR}"/${PN}-1.13.0-setup.patch \
		"${FILESDIR}"/${PN}-2.0.0-emptyso.patch \

	# Set build dir for pytorch's setup
	sed -i \
		-e "/BUILD_DIR/s|build|/var/lib/caffe2/|" \
		tools/setup_helpers/env.py \
		|| die
	distutils-r1_src_prepare

	sed -e "s,\${ROCM_PATH}/lib,\${ROCM_PATH}/$(get_libdir),g" -i cmake/public/LoadHIP.cmake || die

	if use rocm; then
		ebegin "HIPifying cuda sources"
		${EPYTHON} tools/amd_build/build_amd.py || die
		eend $?
		for rocm_lib in rocblas hipfft hipsparse; do
			sed -e "/#include <${rocm_lib}.h>/s,${rocm_lib}.h,${rocm_lib}/${rocm_lib}.h," \
				-i $(grep -rl "#include <${rocm_lib}.h>" .) || die

		done

		sed -e "/#include <hipfftXt.h>/s,hipfftXt.h,hipfft/hipfftXt.h," \
			-i $(grep -rl "#include <hipfftXt.h>" .) || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DUSE_ROCM=? $(usex rocm) 1 : 0
	)
	if use rocm; then
			mycmakeargs+=(
			-DPYTORCH_ROCM_ARCH="$(get_amdgpu_flags)"
			-DROCM_VERSION_DEV_RAW=${ROCM_VERSION}
			-DCMAKE_MODULE_PATH="${EPREFIX}/usr/$(get_libdir)/cmake/hip"
		)
	fi

	use rocm && export HIP_PATH="${EPREFIX}/usr"
	cmake_src_configure
}

src_compile() {
	PYTORCH_BUILD_VERSION=${PV} \
	PYTORCH_BUILD_NUMBER=0 \
	USE_SYSTEM_LIBS=ON \
	CMAKE_BUILD_DIR="${BUILD_DIR}" \
	BUILD_DIR= \
	distutils-r1_src_compile develop sdist
}

src_install() {
	USE_SYSTEM_LIBS=ON distutils-r1_src_install
}
