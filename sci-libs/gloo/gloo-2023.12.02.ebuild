# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
ROCM_VERSION=6.0.0
inherit cmake cuda rocm

CommitId=5354032ea08eadd7fc4456477f7f7c6308818509

DESCRIPTION="library of floating-point neural network inference operators"
HOMEPAGE="https://github.com/facebookincubator/gloo/"
SRC_URI="https://github.com/facebookincubator/${PN}/archive/${CommitId}.tar.gz
	-> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda libuv mpi redis rocm ssl test"

RDEPEND="
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	libuv? ( dev-libs/libuv )
	mpi? ( virtual/mpi )
	redis? (
		dev-db/redis
		dev-libs/hiredis
	)
	rocm? ( dev-util/hip )
	ssl? ( dev-libs/openssl:= )
"
DEPEND="${RDEPEND}
"

BDEPEND="test? ( dev-cpp/gtest )"
RESTRICT="test" # For some test the network is needed

S="${WORKDIR}"/${PN}-${CommitId}

PATCHES=(
	"${FILESDIR}"/${PN}-2022.05.18-gentoo.patch
	"${FILESDIR}"/${PN}-2023.01.17-cuda.patch
	"${FILESDIR}"/${PN}-2023.01.17-ssl3.patch
	"${FILESDIR}"/${PN}-2023.10.24-rocm-6.patch
)

src_prepare() {
	eapply_user
	cmake_src_prepare
	use cuda && cuda_add_sandbox
	sed -e "s,find_package(HIP 1.0),find_package(HIP)," -i cmake/Hip.cmake || die

	if use rocm; then
		ebegin "HIPifying cuda sources"
		# ${EPYTHON} tools/amd_build/build_amd.py --project-directory . --output-directory ? || die
		eend $?
	fi
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TEST=$(usex test ON OFF)
		-DUSE_CUDA=$(usex cuda ON OFF)
		-DUSE_ROCM=$(usex rocm ON OFF)
		-DGLOO_USE_CUDA_TOOLKIT=$(usex cuda ON OFF)
		-DUSE_LIBUV=$(usex libuv ON OFF)
		-DUSE_MPI=$(usex mpi ON OFF)
		-DUSE_REDIS=$(usex redis ON OFF)
		-DUSE_RCCL=$(usex rocm ON OFF)
		-DUSE_TCP_OPENSSL_LINK=$(usex ssl ON OFF)
		-Wno-dev
	)
	if use cuda; then
		mycmakeargs+=(
			-DCMAKE_CUDA_FLAGS="$(cuda_gccdir -f | tr -d \")"
		)
	fi

	if use rocm; then
		export HIP_CLANG_PATH="${EPREFIX}/usr/lib/llvm/17/bin"
		mycmakeargs+=(
			-DGLOO_ROCM_ARCH="$(get_amdgpu_flags)"
			-DROCM_PATH="${EPREFIX}/usr"
			-DCMAKE_MODULE_PATH="${EPREFIX}/usr/$(get_libdir)/cmake/hip"
		)
	fi
	cmake_src_configure
}
