# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{9..12} )

inherit distutils-r1 pypi

DESCRIPTION="Python 3 runtime for ANTLR"
HOMEPAGE="
	https://www.antlr.org/
	https://github.com/antlr/antlr4/
	https://pypi.org/project/antlr4-python3-runtime/
"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

python_test() {
	"${EPYTHON}" tests/run.py -v || die "Tests failed with ${EPYTHON}"
}
