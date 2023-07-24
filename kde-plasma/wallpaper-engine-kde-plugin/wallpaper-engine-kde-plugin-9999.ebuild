# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION=""
HOMEPAGE="https://github.com/catsout/wallpaper-engine-kde-plugin"
if [[ ${PV} == *9999 ]] ; then
	inherit git-r3
	EGIT_SUBMODULES=(src/backend_scene/third_libs/glslang src/backend_scene/third_party/glslang)
	EGIT_REPO_URI="https://github.com/catsout/wallpaper-engine-kde-plugin.git"
	S="${WORKDIR}/${P}"
fi

LICENSE="GNU"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="dev-util/cmake
kde-frameworks/plasma
media-plugins/gst-plugins-libav
media-video/mpv
dev-python/websockets
dev-qt/qtdeclarative:5
dev-qt/qtwebsockets:5
dev-qt/qtwebchannel:5
dev-util/vulkan-headers
"
RDEPEND="${DEPEND}"
BDEPEND=""

PATCHES=(
	"${FILESDIR}/gcc13_cstdio.patch"
)
