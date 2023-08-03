# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )
inherit distutils-r1 pypi

DESCRIPTION=""
HOMEPAGE="
	https://pypi.org/project/torchmetrics/
"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
SRC_URI="https://github.com/Lightning-AI/torchmetrics/releases/download/v${PV}/${P}.tar.gz -> ${P}.tar.gz"
