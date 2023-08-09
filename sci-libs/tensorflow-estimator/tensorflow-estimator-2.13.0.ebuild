# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
MY_PN="estimator"
MY_PV=${PV/_rc/-rc}
MY_P=${MY_PN}-${MY_PV}

inherit bazel distutils-r1 pypi

DESCRIPTION="A high-level TensorFlow API that greatly simplifies machine learning programming"
HOMEPAGE="https://www.tensorflow.org/
https://pypi.org/project/tensorflow-estimator
"

SRC_URI="https://github.com/tensorflow/estimator/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	sci-libs/tensorflow[python,${PYTHON_USEDEP}]
	sci-libs/keras[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"
BDEPEND="
	app-arch/unzip
	dev-java/java-config
	>=dev-util/bazel-5.3.0"

DOCS=( CONTRIBUTING.md README.md )

