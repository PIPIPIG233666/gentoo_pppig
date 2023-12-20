# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=7

inherit cmake git-r3
DESCRIPTION="A flexible and cross platform input method framework"

HOMEPAGE="https://github.com/maliit/framework"
SRC_URI=""
EGIT_REPO_URI="https://github.com/maliit/framework.git"

KEYWORDS="~amd64 ~x86 ~arm64 ~arm"

if [[ ${PV} != 9999 ]]; then
        EGIT_COMMIT="tags/${PV}"
        #EGIT_COMMIT="f9648e8f634e12161caac00e7d7e63a16c7ccdc4"
else
        KEYWORDS=""
fi

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
IUSE="+dbus doc +gtk test"

DEPEND="
	dbus? ( sys-apps/dbus )
	gtk? ( x11-libs/gtk+ )
	dev-qt/qtdeclarative
"

RDEPEND="${DEPEND}"

BDEPEND="
	app-doc/doxygen
	media-gfx/graphviz
"

RESTRICT="test"

#PATCHES=( "${FILESDIR}/${PN}-0.94.0-removeldconfig.patch" )

DOCS=( README )

src_configure() {
	local mycmakeargs=(
		-Denable-docs=$(usex doc ON OFF)
		-Denable-dbus-activation=$(usex dbus ON OFF)
		-Denable-wayland-gtk=$(usex gtk ON OFF)
		-Denable-tests=$(usex test ON OFF)
	)
	use doc && mycmakeargs+=(
		-DDOC_INSTALL_DIR="share/doc/${P}"
	)

	cmake_src_configure
}
