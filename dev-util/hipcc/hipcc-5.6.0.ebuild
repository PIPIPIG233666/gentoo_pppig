# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake llvm prefix

LLVM_MAX_SLOT=16

DESCRIPTION="HIP compiler driver"
HOMEPAGE="https://github.com/ROCm-Developer-Tools/HIPCC"
SRC_URI="https://github.com/ROCm-Developer-Tools/HIPCC/archive/rocm-${PV}.tar.gz -> rocm-hipcc-${PV}.tar.gz"

KEYWORDS="~amd64"
LICENSE="MIT"
SLOT="0/$(ver_cut 1-2)"

IUSE=""

DEPEND=""

RDEPEND="${DEPEND}"

S="${WORKDIR}/HIPCC-rocm-${PV}"

PATCHES=(
"${FILESDIR}/${PN}-9999-rocm-path.patch"
)

src_prepare() {
	cmake_src_prepare

	local LLVM_PREFIX="$(get_llvm_prefix "${LLVM_MAX_SLOT}")"

	# Setting HSA_PATH to "/usr" results in setting "-isystem /usr/include"
	# which makes "stdlib.h" not found when using "#include_next" in header files;
	sed -e "/FLAGS .= \" -isystem \$HSA_PATH/d" \
		-e "/HIP.*FLAGS.*isystem.*HIP_INCLUDE_PATH/d" \
		-e "s:\$ENV{'DEVICE_LIB_PATH'}:'${EPREFIX}/usr/lib/amdgcn/bitcode':" \
		-e "s:\$ENV{'HIP_LIB_PATH'}:'${EPREFIX}/usr/$(get_libdir)':" -i bin/hipcc.pl || die

	einfo "prefixing hipcc and its utils..."
	hprefixify $(grep -rl --exclude-dir=build/ --exclude="hip-config.cmake.in" "/usr" "${S}")
	hprefixify $(grep -rl --exclude-dir=build/ --exclude="hipcc.pl" "/usr" "${HIP_S}")

	mv bin/hipvars.pm "${T}"/
	cp "$(prefixify_ro "${FILESDIR}"/hipvars-5.3.3.pm)" bin/hipvars.pm || die "failed to replace hipvars.pm"
	sed -e "s,@HIP_BASE_VERSION_MAJOR@,$(ver_cut 1)," -e "s,@HIP_BASE_VERSION_MINOR@,$(ver_cut 2)," \
		-e "s,@HIP_VERSION_PATCH@,$(ver_cut 3)," -i bin/hipvars.pm
	sed	-e "s,@CLANG_PATH@,${LLVM_PREFIX}/bin," -i bin/hipvars.pm || die

}

