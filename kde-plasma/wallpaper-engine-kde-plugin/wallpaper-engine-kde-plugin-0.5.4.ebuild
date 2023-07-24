# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit ecm

DESCRIPTION=""
HOMEPAGE="https://github.com/catsout/wallpaper-engine-kde-plugin"
HASH_GLSLANG=73c9630da979017b2f7e19c6549e2bdb93d9b238
if [[ ${PV} == *9999 ]] ; then
	inherit git-r3
	EGIT_SUBMODULES=(src/backend_scene/third_libs/glslang src/backend_scene/third_party/glslang)
	EGIT_REPO_URI="https://github.com/catsout/wallpaper-engine-kde-plugin.git"
	S="${WORKDIR}/${P}"
else
	KEYWORDS="~amd64"
	SRC_URI="https://github.com/catsout/wallpaper-engine-kde-plugin/archive/refs/tags/v${PV}.tar.gz
						-> ${P}.tar.gz
			https://github.com/KhronosGroup/glslang/archive/${HASH_GLSLANG}.tar.gz
                        -> glslang-${HASH_GLSLANG}.tar.gz"
fi

LICENSE="GNU"
SLOT="0"

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

CMAKE_BUILD_TYPE=Release

PATCHES=(
	"${FILESDIR}/gcc13_cstdio.patch"
)

src_prepare () {
	rmdir "${S}"/src/backend_scene/third_party/glslang || die
	mkdir -p "${S}"/src/backend_scene/third_libs/glslang || die
	cp -r "${WORKDIR}"/glslang-${HASH_GLSLANG} "${S}"/src/backend_scene/third_libs/glslang || die
	cp -r "${WORKDIR}"/glslang-${HASH_GLSLANG} "${S}"/src/backend_scene/third_party/glslang || die

	ecm_src_prepare
}

