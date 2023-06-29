# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )

inherit meson python-single-r1 xdg

DESCRIPTION="GTK application to configure gaming devices"
HOMEPAGE="https://github.com/libratbag/piper"
if [[ ${PV} == *9999 ]] ; then
	inherit git-r3
	EGIT_SUBMODULES=()
	EGIT_REPO_URI="https://github.com/libratbag/piper.git"
else
	SRC_URI="https://github.com/libratbag/piper/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-2"
SLOT="0"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

BDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/lxml[${PYTHON_USEDEP}]
	')
	virtual/pkgconfig
	dev-libs/appstream
"
RDEPEND="
	${PYTHON_DEPS}
	dev-libs/gobject-introspection
	>=dev-libs/libratbag-0.14
	gnome-base/librsvg[introspection]
	x11-libs/gdk-pixbuf[introspection]
	x11-libs/gtk+:3[introspection]
	$(python_gen_cond_dep '
		dev-python/lxml[${PYTHON_USEDEP}]
		dev-python/pycairo[${PYTHON_USEDEP}]
		dev-python/pygobject:3[cairo,${PYTHON_USEDEP}]
		dev-python/python-evdev[${PYTHON_USEDEP}]
	')
"
DEPEND="
	${RDEPEND}
	dev-libs/libevdev
	virtual/libudev
"

src_configure() {
	python_setup

	meson_src_configure
}

src_install() {
	meson_src_install
	python_optimize
	python_fix_shebang "${ED}"/usr/bin/
}
