# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 pypi

DESCRIPTION=""
HOMEPAGE="
	https://pypi.org/project/albumentations/
"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
>=dev-python/numpy-1.11.1
>=dev-python/scipy-1.1.0
>=dev-python/scikit-image-0.16.1
dev-python/pyyaml
>=dev-python/qudida-0.0.4
"
