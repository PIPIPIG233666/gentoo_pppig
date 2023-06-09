# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 pypi

DESCRIPTION="A neural network trained on a variety of (image, text) pairs."
HOMEPAGE="
https://github.com/openai/CLIP/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

CLIP_COMMIT="d50d76daa670286dd6cacf3bcd80b5e4823fc8e1"
SRC_URI="https://github.com/openai/CLIP/archive/${CLIP_COMMIT}.tar.gz -> CLIP-${CLIP_COMMMIT}.tar.gz"
S="${WORKDIR}/${PN}-${CLIP_COMMIT}"
