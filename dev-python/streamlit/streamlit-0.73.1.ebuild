# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 pypi

DESCRIPTION=""
HOMEPAGE="
	https://pypi.org/project/streamlit/
"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
dev-python/pipenv
dev-python/altair
dev-python/blinker
dev-python/cachetools
dev-python/click
dev-python/importlib-metadata
dev-python/numpy
dev-python/packaging
dev-python/pandas
dev-python/pillow
dev-python/protobuf-python
dev-python/pyarrow
dev-python/Pympler
dev-python/python-dateutil
dev-python/requests
dev-python/rich
dev-python/tenacity
dev-python/toml
dev-python/typing-extensions
dev-python/tzlocal
dev-python/validators
dev-python/watchdog
"
