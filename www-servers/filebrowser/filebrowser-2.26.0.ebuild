# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

# downloading go mods to vendor
# GOMODCACHE="${PWD}"/go-mod go mod download -modcacherw

# downloading node modules
# npm install

# uploading to gh rel
# tar -zcvf node-modules.tar.gz frontend/node_modules
# tar -zcvf go-vendor.tar.gz go-mod
# gh release upload filebrowser-2.26.0 ~/filebrowser/node-modules.tar.gz
# gh release upload filebrowser-2.26.0 ~/filebrowser/go-vendor.tar.gz

MY_NODE_N="node_modules"
MY_NODE_DIR="${S}/frontend/${MY_NODE_N}/"

DESCRIPTION="Web File Browser"
HOMEPAGE="https://filebrowser.org/"
SRC_URI="https://github.com/filebrowser/filebrowser/archive/v${PV}.tar.gz -> ${P}.tar.gz
https://github.com/PIPIPIG233666/gentoo_pppig/releases/download/${P}/go-vendor.tar.gz -> ${PN}-dep-go-${PV}.tar.gz
https://github.com/PIPIPIG233666/gentoo_pppig/releases/download/${P}/node-modules.tar.gz -> ${PN}-dep-node-${PV}.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"

DEPEND="
acct-group/filebrowser
acct-user/filebrowser"
RDEPEND="${DEPEND}"
BDEPEND="net-libs/nodejs"

src_prepare() {
	default
	# We will use pre-generated npm stuff.
	mv "${WORKDIR}/frontend/${MY_NODE_N}" "${MY_NODE_DIR}" || die "couldn't move node_modules"
}

src_configure() {
	export NODE_OPTIONS=--openssl-legacy-provider
	export VERSION=${PV}
	export GOGC=off
	default
}

src_compile() {
	cd frontend && npm run build || die "building npm frontend failed"
	cd "${S}" && go build . || die "building go backend failed"
}

src_install() {
	dobin ${PN}
}
