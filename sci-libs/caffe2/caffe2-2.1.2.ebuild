# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
ROCM_VERSION=6.0.0
PYTHON_COMPAT=( python3_{10..12} )
inherit python-single-r1 cmake cuda flag-o-matic prefix rocm

MYPN=pytorch
MYP=${MYPN}-${PV}

DESCRIPTION="A deep learning framework"
HOMEPAGE="https://pytorch.org/"
SRC_URI="https://github.com/pytorch/${MYPN}/archive/refs/tags/v${PV}.tar.gz
	-> ${MYP}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cuda distributed fbgemm ffmpeg gloo mpi nnpack +numpy opencl opencv openmp qnnpack rocm tensorpipe xnnpack"
RESTRICT="test"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	ffmpeg? ( opencv )
	mpi? ( distributed )
	tensorpipe? ( distributed )
	distributed? ( tensorpipe )
	gloo? ( distributed )
	rocm? ( ${ROCM_REQUIRED_USE} )
	?? ( cuda rocm )
"

# CUDA 12 not supported yet: https://github.com/pytorch/pytorch/issues/91122
RDEPEND="
	${PYTHON_DEPS}
	dev-cpp/gflags:=
	>=dev-cpp/glog-0.5.0
	dev-libs/cpuinfo
	dev-libs/libfmt
	dev-libs/protobuf:=
	dev-libs/pthreadpool
	dev-libs/sleef
	sci-libs/lapack
	>=sci-libs/onnx-1.12.0
	sci-libs/foxi
	cuda? (
		=dev-libs/cudnn-8*
		dev-libs/cudnn-frontend:0/8
		<dev-util/nvidia-cuda-toolkit-12:=[profiler]
	)
	fbgemm? ( dev-libs/FBGEMM )
	ffmpeg? ( media-video/ffmpeg:= )
	gloo? ( sci-libs/gloo[cuda?] )
	mpi? ( virtual/mpi )
	nnpack? ( sci-libs/NNPACK )
	numpy? ( $(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_USEDEP}]
		') )
	opencl? ( virtual/opencl )
	opencv? ( media-libs/opencv:= )
	rocm? (
		dev-util/hip
		dev-util/roctracer
		dev-libs/rccl[${ROCM_USEDEP}]
		sci-libs/hipCUB[${ROCM_USEDEP}]
		sci-libs/hipFFT[${ROCM_USEDEP}]
		sci-libs/hipSOLVER[${ROCM_USEDEP}]
		sci-libs/hipSPARSE[${ROCM_USEDEP}]
		sci-libs/miopen[${ROCM_USEDEP}]
		sci-libs/rocBLAS[${ROCM_USEDEP}]
		sci-libs/rocFFT[${ROCM_USEDEP}]
		sci-libs/rocPRIM[${ROCM_USEDEP}]
		sci-libs/rocRAND[${ROCM_USEDEP}]
		sci-libs/rocSOLVER[${ROCM_USEDEP}]
		sci-libs/rocSPARSE[${ROCM_USEDEP}]
		sci-libs/rocThrust[${ROCM_USEDEP}]
	)
	qnnpack? ( sci-libs/QNNPACK )
	tensorpipe? ( sci-libs/tensorpipe[cuda?] )
	xnnpack? ( >=sci-libs/XNNPACK-2022.12.22 )
"
DEPEND="
	${RDEPEND}
	dev-cpp/eigen
	cuda? ( dev-libs/cutlass )
	dev-libs/psimd
	dev-libs/FP16
	dev-libs/FXdiv
	dev-libs/pocketfft
	dev-libs/flatbuffers
	sci-libs/kineto
	$(python_gen_cond_dep '
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/pybind11[${PYTHON_USEDEP}]
	')
"

S="${WORKDIR}"/${MYP}

PATCHES=(
	"${FILESDIR}"/0001-${PN}-2.1-rocm-6.patch
	"${FILESDIR}"/0002-${PN}-2.1-rocm-6.patch
	"${FILESDIR}"/0003-${PN}-2.1-rocm-6.patch
	"${FILESDIR}"/0004-${PN}-2.1-rocm-6.patch
	"${FILESDIR}"/${PN}-2.1-gentoo.patch
	"${FILESDIR}"/${PN}-1.13.0-install-dirs.patch
	"${FILESDIR}"/${PN}-1.12.0-glog-0.6.0.patch
	"${FILESDIR}"/${PN}-1.13.1-tensorpipe.patch
	"${FILESDIR}"/${PN}-2.0.0-gcc13.patch
	"${FILESDIR}"/${PN}-2.0.0-cudnn_include_fix.patch
	"${FILESDIR}"/find-hip.patch
	"${FILESDIR}"/specify-rocm-arch.patch
	"${FILESDIR}"/disable-frexp.patch
)

src_prepare() {
	filter-lto #bug 862672
	sed -i \
		-e "/third_party\/gloo/d" \
		cmake/Dependencies.cmake \
		|| die
	cmake_src_prepare
	pushd torch/csrc/jit/serialization || die
	flatc --cpp --gen-mutable --scoped-enums mobile_bytecode.fbs || die
	popd
	# prefixify the hardcoded paths, after all patches are applied
	hprefixify \
		aten/CMakeLists.txt \
		caffe2/CMakeLists.txt \
		cmake/Metal.cmake \
		cmake/Modules/*.cmake \
		cmake/Modules_CUDA_fix/FindCUDNN.cmake \
		cmake/Modules_CUDA_fix/upstream/FindCUDA/make2cmake.cmake \
		cmake/Modules_CUDA_fix/upstream/FindPackageHandleStandardArgs.cmake \
		cmake/public/LoadHIP.cmake \
		cmake/public/cuda.cmake \
		cmake/Dependencies.cmake \
		torch/CMakeLists.txt \
		CMakeLists.txt



	if use rocm; then
		# ebegin "HIPifying cuda sources"
		# ${EPYTHON} tools/amd_build/build_amd.py || die
		# eend $?
		# for rocm_lib in rocblas hipfft hipsparse; do
			# sed -e "/#include <${rocm_lib}.h>/s,${rocm_lib}.h,${rocm_lib}/${rocm_lib}.h," \
				# -i $(grep -rl "#include <${rocm_lib}.h>" .) || die
#
		# done
#
		# sed -e "/#include <hipfftXt.h>/s,hipfftXt.h,hipfft/hipfftXt.h," \
			# -i $(grep -rl "#include <hipfftXt.h>" .) || die
		local HIP_VERSION="$(hipconfig -v)"
		local HIP_VERSION="${HIP_VERSION/-}"
		sed -e "/rocm_version = /s:(0, 0, 0):(${HIP_VERSION//./, }):" -i torch/utils/hipify/cuda_to_hip_mappings.py || die
		sed -e "/set(roctracer_INCLUDE_DIRS/s,\${ROCTRACER_PATH}/include,${EPREFIX}/usr/include/roctracer," \
			-e "/PYTORCH_HIP_HCC_LIBRARIES/s,\${HIP_PATH}/lib,${EPREFIX}/usr/$(get_libdir)," \
			-e "/set(roctracer_INCLUDE_DIRS/a\  set(thrust_INCLUDE_DIRS ${EPREFIX}/usr/include/rocthrust)" \
			-e "s,\${ROCTRACER_PATH}/lib,${EPREFIX}/usr/lib64/roctracer," \
			-e "/READ.*\.info\/version-dev/c\  set(ROCM_VERSION_DEV_RAW ${HIP_VERSION})" \
			-i cmake/public/LoadHIP.cmake || die
			# sed -r -e '/^if\(USE_ROCM/{:a;N;/\nendif/!ba; s,\{([^\{]*)_PATH\}(/include)?,\{\L\1_\UINCLUDE_DIRS\},g}' -i cmake/Dependencies.cmake || die
		ebegin "HIPifying cuda sources"
		${EPYTHON} tools/amd_build/build_amd.py || die
		eend $?
	fi
}

src_configure() {
	if use cuda && [[ -z ${TORCH_CUDA_ARCH_LIST} ]]; then
		ewarn "WARNING: caffe2 is being built with its default CUDA compute capabilities: 3.5 and 7.0."
		ewarn "These may not be optimal for your GPU."
		ewarn ""
		ewarn "To configure caffe2 with the CUDA compute capability that is optimal for your GPU,"
		ewarn "set TORCH_CUDA_ARCH_LIST in your make.conf, and re-emerge caffe2."
		ewarn "For example, to use CUDA capability 7.5 & 3.5, add: TORCH_CUDA_ARCH_LIST=7.5 3.5"
		ewarn "For a Maxwell model GPU, an example value would be: TORCH_CUDA_ARCH_LIST=Maxwell"
		ewarn ""
		ewarn "You can look up your GPU's CUDA compute capability at https://developer.nvidia.com/cuda-gpus"
		ewarn "or by running /opt/cuda/extras/demo_suite/deviceQuery | grep 'CUDA Capability'"
	fi

	local mycmakeargs=(
		-DBUILD_CUSTOM_PROTOBUF=OFF
		-DBUILD_SHARED_LIBS=ON

		-DUSE_CCACHE=OFF
		-DUSE_CUDA=$(usex cuda)
		-DUSE_CUDNN=$(usex cuda)
		-DUSE_FAST_NVCC=$(usex cuda)
		-DTORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST:-3.5 7.0}"
		-DBUILD_NVFUSER=OFF
		-DUSE_DISTRIBUTED=$(usex distributed)
		-DUSE_MPI=$(usex mpi)
		-DUSE_FAKELOWP=OFF
		-DUSE_FBGEMM=$(usex fbgemm)
		-DUSE_FFMPEG=$(usex ffmpeg)
		-DUSE_GFLAGS=ON
		-DUSE_GLOG=ON
		-DUSE_GLOO=$(usex gloo)
		-DUSE_KINETO=OFF # TODO
		-DUSE_LEVELDB=OFF
		-DUSE_MAGMA=OFF # TODO: In GURU as sci-libs/magma
		-DUSE_MKLDNN=OFF
		-DUSE_NCCL=OFF # TODO: NVIDIA Collective Communication Library
		-DUSE_NNPACK=$(usex nnpack)
		-DUSE_QNNPACK=$(usex qnnpack)
		-DUSE_XNNPACK=$(usex xnnpack)
		-DUSE_SYSTEM_XNNPACK=$(usex xnnpack)
		-DUSE_TENSORPIPE=$(usex tensorpipe)
		-DUSE_PYTORCH_QNNPACK=OFF
		-DUSE_NUMPY=$(usex numpy)
		-DUSE_OPENCL=$(usex opencl)
		-DUSE_OPENCV=$(usex opencv)
		-DUSE_OPENMP=$(usex openmp)
		-DUSE_ROCM=$(usex rocm)
		-DUSE_SYSTEM_CPUINFO=ON
		-DUSE_SYSTEM_PYBIND11=ON
		-DUSE_UCC=OFF
		-DUSE_VALGRIND=OFF
		-DPYBIND11_PYTHON_VERSION="${EPYTHON#python}"
		-DPYTHON_EXECUTABLE="${PYTHON}"
		-DUSE_ITT=OFF
		-DBLAS=Eigen # avoid the use of MKL, if found on the system
		-DUSE_SYSTEM_EIGEN_INSTALL=ON
		-DUSE_SYSTEM_PTHREADPOOL=ON
		-DUSE_SYSTEM_FXDIV=ON
		-DUSE_SYSTEM_FP16=ON
		-DUSE_SYSTEM_GLOO=ON
		-DUSE_SYSTEM_ONNX=ON
		-DUSE_SYSTEM_SLEEF=ON

		-Wno-dev
		-DTORCH_INSTALL_LIB_DIR="${EPREFIX}"/usr/$(get_libdir)
		-DLIBSHM_INSTALL_LIB_SUBDIR="${EPREFIX}"/usr/$(get_libdir)
	)

	if use cuda; then
		addpredict "/dev/nvidiactl" # bug 867706
		addpredict "/dev/char"

		mycmakeargs+=(
			-DCMAKE_CUDA_FLAGS="$(cuda_gccdir -f | tr -d \")"
		)
	fi

	if use rocm; then
		export HIPCUB_PATH="${EPREFIX}"/usr
		export HIPFFT_PATH="${EPREFIX}"/usr
		export HIPRAND_PATH="${EPREFIX}"/usr
		export HIPSOLVER_PATH="${EPREFIX}"/usr
		export HIPSPARSE_PATH="${EPREFIX}"/usr
		export HIP_CLANG_PATH="${EPREFIX}/usr/lib/llvm/17/bin"
		export HIP_PATH="${EPREFIX}"/usr
		export HSA_PATH="${EPREFIX}"/usr
		export MIOPEN_PATH="${EPREFIX}"/usr
		export RCCL_PATH="${EPREFIX}"/usr
		export ROCBLAS_PATH="${EPREFIX}"/usr
		export ROCFFT_PATH="${EPREFIX}"/usr
		export ROCM_PATH="${EPREFIX}"/usr
		export ROCPRIM_PATH="${EPREFIX}"/usr
		export ROCRAND_PATH="${EPREFIX}"/usr
		export ROCSOLVER_PATH="${EPREFIX}"/usr
		export ROCSPARSE_PATH="${EPREFIX}"/usr
		export ROCTHRUST_PATH="${EPREFIX}"/usr
		export ROCTRACER_PATH="${EPREFIX}"/usr
		export THRUST_PATH="${EPREFIX}"/usr
		mycmakeargs+=(
		    -DPYTORCH_ROCM_ARCH="$(get_amdgpu_flags)"
			-DROCM_VERSION_DEV_RAW=${ROCM_VERSION}
			-DTORCH_HIP_VERSION=${HIP_VERSION}
			-DCMAKE_MODULE_PATH="${EPREFIX}/usr/$(get_libdir)/cmake/hip"
		)
	fi

	if use rocm; then
		addpredict /dev/kfd
		addpredict /dev/dri/
	fi
	cmake_src_configure
}

src_install() {
	cmake_src_install

	insinto "/var/lib/${PN}"
	doins "${BUILD_DIR}"/CMakeCache.txt

	rm -rf python
	mkdir -p python/torch/include || die
	mv "${ED}"/usr/lib/python*/site-packages/caffe2 python/ || die
	mv "${ED}"/usr/include/torch python/torch/include || die
	cp torch/version.py python/torch/ || die
	rm -rf "${ED}"/var/tmp || die
	python_domodule python/caffe2
	python_domodule python/torch
}
