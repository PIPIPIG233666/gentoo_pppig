# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 pypi

DESCRIPTION=""
HOMEPAGE="
	https://pypi.org/project/test-tube/
"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"

src_prepare() {
        default
        rm -r "examples" || die "rm failed"
}
