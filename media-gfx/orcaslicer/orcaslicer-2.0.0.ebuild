# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

WX_GTK_VER="3.2-gtk3"
MY_PN="OrcaSlicer"
MY_PV="$(ver_rs 3 -)"

inherit cmake wxwidgets xdg

DESCRIPTION="A mesh slicer to generate G-code for fused-filament-fabrication (3D printers)"
HOMEPAGE="https://github.com/SoftFever/OrcaSlicer"
SRC_URI="https://github.com/SoftFever/OrcaSlicer/archive/refs/tags/v${MY_PV}.tar.gz -> ${P}.tar.gz"
SoftFever/OrcaSlicer
S="${WORKDIR}/${MY_PN}-${MY_PV}"
LICENSE="AGPL-3 Boost-1.0 GPL-2 LGPL-3 MIT"
SLOT="0"
KEYWORDS="amd64 arm64 ~x86"
IUSE="test"

RESTRICT="!test? ( test )"


RDEPEND="
	dev-cpp/eigen:3
	dev-cpp/tbb:=
	dev-libs/boost:=[nls]
	dev-libs/cereal
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/gmp:=
	dev-libs/log4cplus:=
	dev-libs/mpfr:=
	media-gfx/openvdb:=
	media-gfx/libbgcode
	net-misc/curl[adns]
	media-libs/glew:0=
	media-libs/glfw:=
	media-libs/libjpeg-turbo:=
	media-libs/libpng:0=
	media-libs/mesa:=[osmesa]
	media-libs/qhull:=
	sci-libs/libigl
	sci-libs/nlopt
	sci-libs/opencascade:=
	sci-mathematics/cgal:=
	sys-apps/dbus
	sys-libs/zlib:=
	virtual/opengl
	x11-libs/gtk+:3
	>=x11-libs/wxGTK-3.2.2.1-r3:${WX_GTK_VER}[X,opengl,curl,webkit]
	media-libs/nanosvg:=
"
DEPEND="${RDEPEND}
	media-libs/qhull[static-libs]
	test? ( =dev-cpp/catch-2* )
"


PATCHES=(
        "${FILESDIR}/${PN}-2.0.0_link_to_libwebkit2gtk-4.1.patch"
        "${FILESDIR}/${PN}-2.0.0_MeshBoolean_dyn_link_boost.patch"
        "${FILESDIR}/${PN}-2.0.0_missing_include.patch"
        "${FILESDIR}/${PN}-2.0.0_wxgtk3-wayland-fix.patch"
        "${FILESDIR}/${PN}-2.0.0_skip_install_licence_file.patch"
)

src_configure() {
	CMAKE_BUILD_TYPE="Release"

	setup-wxwidgets

	local mycmakeargs=(
		-DOPENVDB_FIND_MODULE_PATH="/usr/$(get_libdir)/cmake/OpenVDB"

		-DSLIC3R_BUILD_TESTS=$(usex test)
		-DSLIC3R_FHS=ON
		-DSLIC3R_GTK=3
		-DSLIC3R_GUI=ON
		-DSLIC3R_PCH=OFF
		-DSLIC3R_STATIC=OFF
		-DSLIC3R_WX_STABLE=OFF
                -DORCA_TOOLS=ONE
                -DBBL_RELEASE_TO_PUBLIC=ON
                -DBBL_INTERNAL_TESTING=$(usex test)
		-Wno-dev
	)

	cmake_src_configure
}

src_test() {
	CMAKE_SKIP_TESTS=(
		"^libslic3r_tests$"
	)
	cmake_src_test
}
