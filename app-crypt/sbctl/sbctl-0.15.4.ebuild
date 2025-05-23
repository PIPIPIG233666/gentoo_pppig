# Copyright 2022-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go go-module optfeature verify-sig

DESCRIPTION="Secure Boot key manager"
HOMEPAGE="https://github.com/Foxboron/sbctl"
SRC_URI="https://github.com/Foxboron/${PN}/releases/download/${PV}/${P}.tar.gz
	verify-sig? ( https://github.com/Foxboron/${PN}/releases/download/${PV}/${P}.tar.gz.sig )"
# SRC_URI+=" https://dev.gentoo.org/~ajak/distfiles/${CATEGORY}/${PN}/${P}-deps.tar.xz"
SRC_URI+=" https://github.com/PIPIPIG233666/gentoo_pppig/releases/download/${P}/go-mod.tar.gz -> ${P}-go-mod.tar.gz"

LICENSE="Apache-2.0 BSD BSD-2 MIT"
SLOT="0"
KEYWORDS="amd64"

BDEPEND="app-text/asciidoc
	verify-sig? ( sec-keys/openpgp-keys-foxboron )"

VERIFY_SIG_OPENPGP_KEY_PATH="/usr/share/openpgp-keys/foxboron.asc"

PATCHES=(
)

src_unpack() {
	if use verify-sig; then
		verify-sig_verify_detached "${DISTDIR}"/${P}.tar.gz{,.sig}
	fi

	default
	go_setup_vendor
}

src_compile() {
	go_src_compile
}

src_install() {
	# go_src_install
	emake PREFIX="${ED}/usr" install
}

pkg_postinst() {
	optfeature "automatically signing installed kernels with sbctl keys on each kernel installation" \
		"sys-kernel/installkernel[systemd]"
}
