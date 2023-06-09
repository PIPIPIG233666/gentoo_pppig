# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )
inherit distutils-r1

DESCRIPTION=""
HOMEPAGE="
	https://pypi.org/project/clean-fid/
"

SRC_URI="
https://github.com/GaParmar/clean-fid/archive/main/${PN}.tar.gz
	-> ${P}.gh.tar.gz
"
S="${WORKDIR}/${PN}-main"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
