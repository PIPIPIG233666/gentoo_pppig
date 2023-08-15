# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd

DESCRIPTION="Simple script to control power states of amdgpu driven GPUs"
HOMEPAGE="https://github.com/sibradzic/amdgpu-clocks"
SRC_URI="https://github.com/sibradzic/amdgpu-clocks/archive/refs/heads/master.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-master"

LICENSE="GNU V2"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="sys-apps/systemd"
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	sed -e 's,local/,,g' -i amdgpu-clocks.service || die	
	dobin amdgpu-clocks
	insinto /etc/systemd/system/
	doins amdgpu-clocks.service
	insinto /usr/lib/systemd/system-sleep/
	doins amdgpu-clocks-resume
}
