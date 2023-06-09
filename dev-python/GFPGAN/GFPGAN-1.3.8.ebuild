# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 pypi

DESCRIPTION="GFPGAN aims at developing Practical Algorithms for Real-world Face Restoration"
HOMEPAGE="
https://github.com/TencentARC/GFPGAN
https://pypi.org/project/gfpgan/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
