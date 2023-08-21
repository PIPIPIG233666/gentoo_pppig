# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

MY_NODE_N="node_modules"
MY_NODE_DIR="${S}/frontend/${MY_NODE_N}/"

DESCRIPTION="Web File Browser"
HOMEPAGE="https://filebrowser.org/"
SRC_URI="https://github.com/filebrowser/filebrowser/archive/v${PV}.tar.gz -> ${P}.tar.gz
https://media.githubusercontent.com/media/PIPIPIG233666/gentoo_pppig/main/${PN}-dep-node-${PV}.tar.gz -> ${PN}-dep-node-${PV}.tar.gz
https://github.com/PIPIPIG233666/gentoo_pppig/raw/main/${PN}-dep-go-${PV}.tar.gz -> ${PN}-dep-go-${PV}.tar.gz
"

LICENSE="Apache 2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="net-libs/nodejs"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	default
	# We will use pre-generated npm stuff.
	mv "${WORKDIR}/${MY_NODE_N}" "${MY_NODE_DIR}" || die "couldn't move node_modules"
}

src_configure() {
	export NODE_OPTIONS=--openssl-legacy-provider
	export VERSION=${PV}
	export GOGC=off
	default
}

src_compile() {
	cd frontend && npm run build || die "building npm frontend failed"
	cd ${S} && go build . || die "building go backend failed"
}

src_install() {
	dobin ${PN}
}
