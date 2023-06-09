# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CARGO_OPTIONAL=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )

CRATES="
	autocfg-1.1.0
	bitflags-1.1.0
	cfg-if-1.0.0
	indoc-1.0.3
	itoa-1.0.6
	libc-0.2.143
	lock_api-0.4.6
	memmap2-0.5.0
	memoffset-0.8.0
	once_cell-1.18.0
	parking_lot-0.12.0
	parking_lot_core-0.9.0
	proc-macro2-1.0.60
	pyo3-0.18.1
	pyo3-build-config-0.18.1
	pyo3-ffi-0.18.1
	pyo3-macros-0.18.1
	pyo3-macros-backend-0.18.1
	quote-1.0.28
	redox_syscall-0.2.8
	ryu-1.0.13
	scopeguard-1.1.0
	serde-1.0.100
	serde_derive-1.0.100
	serde_json-1.0.96
	smallvec-1.10.0
	syn-1.0.85
	target-lexicon-0.12.0
	unicode-ident-1.0.9
	unicode-xid-0.2.4
	unindent-0.1.7
	windows-sys-0.29.0
	windows_aarch64_msvc-0.29.0
	windows_i686_gnu-0.29.0
	windows_i686_msvc-0.29.0
	windows_x86_64_gnu-0.29.0
	windows_x86_64_msvc-0.29.0

"
inherit cargo distutils-r1 pypi

DESCRIPTION=""
HOMEPAGE="
	https://pypi.org/project/safetensors/
"

SRC_URI+="
	$(cargo_crate_uris ${CRATES})
"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	dev-python/setuptools-rust[${PYTHON_USEDEP}]
"

# Rust does not respect CFLAGS/LDFLAGS
QA_FLAGS_IGNORED=".*/_rust.*"

src_unpack() {
	cargo_src_unpack
}
