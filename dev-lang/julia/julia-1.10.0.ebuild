# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# correct versions for stdlibs are in deps/checksums
# for everything else, run with network-sandbox and wait for the crash

EAPI=8

MY_LLVM_V=18.1.2

PYTHON_COMPAT=( python3_{10..12} )

inherit check-reqs flag-o-matic optfeature pax-utils python-any-r1 toolchain-funcs

DESCRIPTION="High-performance programming language for technical computing"
HOMEPAGE="https://julialang.org/
	https://github.com/JuliaLang/julia/"
SRC_URI="
	https://github.com/JuliaLang/julia/releases/download/v${PV}/${P}-full.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
PROPERTIES="test_network"
RESTRICT="test"

RDEPEND="
	>=dev-libs/libutf8proc-2.6.1:0=[-cjk]
	>=dev-util/patchelf-0.13
	>=net-libs/mbedtls-2.2
	>=sci-mathematics/dsfmt-2.2.4
	>=sys-libs/libunwind-1.1:0=
	>=virtual/blas-3.6
	app-arch/p7zip
	app-misc/ca-certificates
	dev-libs/gmp:0=
	dev-libs/libgit2:0
	dev-libs/mpfr:0=
	net-misc/curl[http2,ssh]
	sci-libs/amd:0=
	sci-libs/arpack:0=
	sci-libs/btf:0=
	sci-libs/camd:0=
	sci-libs/ccolamd:0=
	sci-libs/cholmod:0=
	sci-libs/colamd:0=
	sci-libs/fftw:3.0=[threads]
	sci-libs/klu:0=
	sci-libs/ldl:0=
	sci-libs/openlibm:0=
	sci-libs/openblas:0=
	sci-libs/spqr:0=
	sci-libs/suitesparseconfig:0=
	sci-libs/umfpack:0=
	sys-libs/zlib:0=
	virtual/lapack
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	dev-util/cmake
	virtual/pkgconfig
"

CHECKREQS_DISK_BUILD="4G"
PATCHES=(
	"${FILESDIR}"/julia-1.10.0-cuda.patch
	"${FILESDIR}"/julia-1.10.0-libgit2.patch
	# "${FILESDIR}"/julia-1.10.0-lib.patch
	"${FILESDIR}"/julia-1.9.4-string-replace.patch
	"${FILESDIR}"/julia-1.10.0-nodoc.patch
	)
QA_FLAGS_IGNORED+='usr/.*/julia/sys.so'  # Julia sysimage generated by bootstrapping.

pkg_setup() {
	check-reqs_pkg_setup
	python-any-r1_pkg_setup
}

src_unpack() {
	local -a tounpack=( ${A} )
	# the main source tree, followed by deps
	unpack "${tounpack[0]}"

	mkdir -p "${S}/deps/srccache/" || die
	local i
	for i in "${tounpack[@]:1}"; do
		cp "${DISTDIR}/${i}" "${S}/deps/srccache/${i#julia-}" || die
	done

	# Extract tarballs for patching.
	# cd "${S}/deps/srccache/" || die
	# tar xf llvm-julia-${MY_LLVM_V}-3.tar.gz || die
}

src_prepare() {
	default

	# Sledgehammer:
	# - prevent fetching of bundled stuff in compile and install phase
	# - respect CFLAGS
	# - respect EPREFIX and Gentoo specific paths

	sed -i \
		-e "\|SHIPFLAGS :=|c\\SHIPFLAGS := ${CFLAGS}" \
		Make.inc || die

	sed -i \
		-e "s|ar -rcs|$(tc-getAR) -rcs|g" \
		src/Makefile || die

	# Blank the tarball checksum check script.
	echo "#!/bin/sh" > deps/tools/jlchecksum || die
}

src_configure() {
	# bug #855602
	filter-lto

	# julia does not play well with the system versions of libuv
	# Fails to compile with libpcre2 on split-usr, bug #893336
	# USE_SYSTEM_LIBM=0 implies using external openlibm
	# Rbio is not available for Gentoo so we usie libsuiteparse locally
	cat <<-EOF > Make.user || die
		LOCALBASE:=${EPREFIX}/usr
		override prefix:=${EPREFIX}/usr
		override libdir:=\$(prefix)/$(get_libdir)
		override CC:=$(tc-getCC)
		override CXX:=$(tc-getCXX)
		override AR:=$(tc-getAR)

		BUNDLE_DEBUG_LIBS:=0
		USE_BINARYBUILDER:=0
		USE_INTEL_JITEVENTS=0
		USE_SYSTEM_CSL:=1
		USE_SYSTEM_LLVM:=0
		USE_SYSTEM_LIBUNWIND:=1
		USE_SYSTEM_PCRE:=0
		USE_SYSTEM_LIBM:=0
		USE_SYSTEM_OPENLIBM:=1
		USE_SYSTEM_DSFMT:=1
		USE_SYSTEM_BLAS:=1
		USE_SYSTEM_LAPACK:=1
		USE_SYSTEM_LIBBLASTRAMPOLINE:=0
		USE_SYSTEM_GMP:=1
		USE_SYSTEM_MPFR:=1
		USE_SYSTEM_LIBSUITESPARSE:=0
		USE_SYSTEM_LIBUV:=0
		USE_SYSTEM_UTF8PROC:=1
		USE_SYSTEM_MBEDTLS:=1
		USE_SYSTEM_LIBSSH2:=1
		USE_SYSTEM_NGHTTP2:=1
		USE_SYSTEM_CURL:=1
		USE_SYSTEM_LIBGIT2:=1
		USE_SYSTEM_PATCHELF:=1
		USE_SYSTEM_ZLIB:=1
		USE_SYSTEM_P7ZIP:=1
		VERBOSE:=1
	EOF
}

src_compile() {
	# Julia accesses /proc/self/mem on Linux.
	addpredict /proc/self/mem

	# Julia expects .so files to be in  lib64 during compilation
	mkdir -p "${S}"/usr/lib || die
	ln -s lib "${S}"/usr/lib64 || die

	emake
	pax-mark m "$(file usr/bin/julia-* | awk -F : '/ELF/ {print $1}')"
}

src_install() {
	emake -j1 install DESTDIR="${D}"
	dodoc CONTRIBUTING.md HISTORY.md NEWS.md README.md THIRDPARTY.md

	local llvmslot=$(ver_cut 1 ${MY_LLVM_V})
	cp "${S}"/usr/lib/libLLVM-${llvmslot}jl.so "${ED}"/usr/$(get_libdir)/julia/ || die
	cp "${S}"/usr/lib/libLLVM-${MY_LLVM_V}jl.so "${ED}"/usr/$(get_libdir)/julia/ || die

	mv "${ED}"/usr/etc/julia "${ED}"/etc || die
	rmdir "${ED}"/usr/etc || die
	# Don't copy documentation due to timeout issues

	# The appdata directory is deprecated.
	mv "${ED}"/usr/share/{appdata,metainfo}/ || die

	# Link ca-certificates.crt, bug: https://bugs.gentoo.org/888978
	dosym -r /etc/ssl/certs/ca-certificates.crt /usr/share/julia/cert.pem

	# Julia always searches for "sys.so" inside "/usr/lib/julia",
	# bug: https://github.com/JuliaLang/julia/issues/49574
	if [[ $(get_libdir) == "lib64" ]] ; then
		insinto /usr/lib/julia
		doins "${ED}"/usr/$(get_libdir)/julia/sys.so
	fi
}

pkg_postinst() {
	optfeature "Julia Plots" sci-visualization/gr
}
