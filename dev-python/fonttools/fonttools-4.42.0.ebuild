# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )
PYTHON_REQ_USE="xml(+)"

inherit distutils-r1 pypi virtualx

DESCRIPTION="Library for manipulating TrueType, OpenType, AFM and Type1 fonts"
HOMEPAGE="
	https://github.com/fonttools/fonttools/
	https://pypi.org/project/fonttools/
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~m68k ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~arm64-macos ~x64-macos"

RDEPEND="
	>=dev-python/fs-2.4.9[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/cython[${PYTHON_USEDEP}]
	test? (
		app-arch/brotli[python,${PYTHON_USEDEP}]
		app-arch/zopfli
	)
"

distutils_enable_tests pytest

