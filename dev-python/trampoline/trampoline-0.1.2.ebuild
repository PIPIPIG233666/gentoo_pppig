# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )
inherit distutils-r1

DESCRIPTION=""
HOMEPAGE="
	https://gitlab.com/ferreum/trampoline
	https://pypi.org/project/trampoline/
"

SRC_URI="
https://gitlab.com/ferreum/trampoline/-/archive/master/trampoline-master.tar.gz
	-> ${P}.tar.gz
"
S="${WORKDIR}/${PN}-master"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
