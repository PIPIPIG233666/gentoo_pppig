# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{10..11} )

inherit distutils-r1 pypi

DESCRIPTION=""
HOMEPAGE="
	https://pypi.org/project/wandb/
"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
