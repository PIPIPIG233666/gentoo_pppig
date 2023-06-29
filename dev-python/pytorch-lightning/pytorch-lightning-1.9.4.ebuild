# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{10..12} )
inherit distutils-r1 pypi

DESCRIPTION=""
HOMEPAGE="
	https://pypi.org/project/pytorch_lightning/
"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"