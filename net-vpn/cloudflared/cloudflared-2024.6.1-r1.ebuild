# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module systemd

GO_MAY_VER=1.22
GO_VER=${GO_MAY_VER}.5

DESCRIPTION="Argo Tunnel client"
HOMEPAGE="https://github.com/cloudflare/cloudflared"
SRC_URI="https://github.com/cloudflare/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
https://codeload.github.com/cloudflare/go/tar.gz/refs/heads/pwu/cf-${GO_VER} -> go-cf-${PV}.tar.gz
"

LICENSE="Cloudflare"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="test" # needs net

BDEPEND="dev-lang/go"

RDEPEND="acct-user/cloudflared"

DOCS=( {CHANGES,README}.md RELEASE_NOTES )

PATCHES=(
)

src_prepare() {
	default

	DATE="$(date -u '+%Y-%m-%d-%H%M UTC')"
	sed -i  -e "s/\${VERSION}/${PV}/" \
		-e "s/\${DATE}/${DATE}/" cloudflared_man_template \
			|| die "sed failed for cloudflared_man_template"
}

src_compile() {
	cd ${WORKDIR}/go-pwu-cf-${GO_VER}/src || die "cd go/src failed"
	export GOROOT_BOOTSTRAP=/usr/lib/go${GO_MAY_VER}/
	./make.bash || die "make.bash failed"
	DATE="$(date -u '+%Y-%m-%d-%H%M UTC')"
	LDFLAGS="-X main.Version=${PV} -X \"main.BuildTime=${DATE}\""
	cd ${S} || die "cd .. failed"
	export PATH=${WORKDIR}/go-pwu-cf-${GO_VER}/bin/:${PATH}
	go build -v -mod=vendor -ldflags="${LDFLAGS}" ./cmd/cloudflared || die "build failed"
}

src_test() {
	go test -v -mod=vendor -work ./... || die "test failed"
}

src_install() {
	einstalldocs
	newman cloudflared_man_template cloudflared.1
	dobin cloudflared
	insinto /etc/cloudflared
	doins "${FILESDIR}"/config.yml
	newinitd "${FILESDIR}"/cloudflared.initd cloudflared
	newconfd "${FILESDIR}"/cloudflared.confd cloudflared
	systemd_dounit "${FILESDIR}"/cloudflared.service
}
