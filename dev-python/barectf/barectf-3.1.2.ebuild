# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{9..11} )

inherit distutils-r1 pypi

DESCRIPTION="Generator of ANSI C tracers which output CTF data streams"
HOMEPAGE="
https://barectf.org/docs/barectf/3.1/index.html
https://pypi.org/project/barectf
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
