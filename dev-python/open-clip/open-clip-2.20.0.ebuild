# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 pypi

DESCRIPTION="An open source implementation of OpenAI's CLIP Contrastive Language-Image Pre-training"
HOMEPAGE="
https://github.com/mlfoundations/open_clip
https://pypi.org/project/open-clip-torch/
"

SRC_URI="
	https://github.com/mlfoundations/open_clip/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
