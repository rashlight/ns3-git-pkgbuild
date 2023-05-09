# Maintainer: An Van Quoc <andtf2002 at gmail dot com>

pkgname="ns3-git"
pkgver=3.38.r195.gcff5678
pkgrel=1
pkgdesc="A discrete-event network simulator for building internet systems (git version)"
arch=("any")
url="https://www.nsnam.org/"
license=("GPL2")

depends=(
  "gcc>=8" "cmake" "cmake-format" "boost" "boost-libs"  # build system
  "sphinx" "texlive-core" # documentation
  "openmpi" "dpdk" "eigen" "qt5-base" "gsl" "python-pygraphviz" "python-gobject" "python-sphinx" # modules
)
makedepends=(
  "mercurial" "git" "bzip2" "tar" "doxygen"
)
optdepends=(
  "ninja: alternative for make"
  "cppyy: python binding and visualizer"
  "netmap: native packet transmission"
  "doxygen: for viewing documentation"
  "dia: for viewing documentation"
)
conflicts=(
  "${pkgname}" "ns3" "ns3-hg"
)

install=$pkgname.install

source=(
  "ns3::git+https://gitlab.com/nsnam/ns-3-dev.git"
  "netanim::git+https://gitlab.com/nsnam/netanim.git"
  "brite::hg+https://code.nsnam.org/BRITE"
  "hg+https://code.nsnam.org/openflow"
  "git+https://github.com/kohler/click.git"

  "dpdk-net-device.patch"
  "ns3.sh"
  "NetAnim.desktop"
)
sha256sums=('SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            'SKIP'
            '7d495d0bc476b8bae1f32bf6d2031d5a0b02d085a43d3a3fa9f7feb710c48470'
            '7d8e6b41c49a9ed55596e1f73f5fe8478b684e1e0eeb61e51ed183edab5aca53'
            '338d9027b3825e6edccf8e87cff15c069c1f2abb6da8fb6bc3401ea8275ef47b')

shopt -s extglob

pkgver() {
  cd "${srcdir}/ns3/"
  git describe --long --abbrev=7 | sed 's/^ns.//;s/\([^-]*-g\)/r\1/;s/-/./g'
}

prepare() {
  # dpdk-net-device.cc uses obsolete function and constant calls
  patch -Np1 \
    -d "${srcdir}/ns3/src/fd-net-device/model" \
    -i "${srcdir}/dpdk-net-device.patch"
}

build() {
  # Brite
  cd "${srcdir}/brite/"
  make

  # Openflow
  cd "${srcdir}/openflow/"
  ./waf configure --prefix="/usr"
  ./waf build

  # Click
  cd "${srcdir}/click/"
  ./configure \
    --enable-userlevel \
    --disable-linuxmodule \
    --enable-nsclick \
    --enable-wifi \
    --prefix=/usr
  make

  # NetAnim
  cd "${srcdir}/netanim/"
  qmake NetAnim.pro
  make

  # Main source
  cd "${srcdir}/ns3/"
  ./ns3 configure \
    --build-profile=default \
    --prefix=/usr \
    --disable-werror \
    --enable-logs \
    --enable-dpdk \
    --enable-eigen \
    --enable-gsl \
    --enable-mpi \
    --enable-des-metrics \
    --enable-examples \
    --enable-tests \
    --enable-python-bindings \
    --enable-build-version \
    --with-brite "${srcdir}/brite/" \
    --with-click "${srcdir}/click/" \
    --with-openflow "${srcdir}/openflow/"
  ./ns3 build
}

package() {
  install -d -m755 "${pkgdir}/usr/bin/"
  install -d -m755 "${pkgdir}/usr/include/ns3/"
  install -d -m775 "${pkgdir}/opt/ns3/"

  # Source
  cp -r "${srcdir}/ns3/" "${pkgdir}/opt/"
  cp -r "${srcdir}/brite/" "${pkgdir}/usr/include/ns3/"
  cp -r "${srcdir}/openflow/" "${pkgdir}/usr/include/ns3/"
  cp -r "${srcdir}/netanim/" "${pkgdir}/usr/include/ns3/"

  # Shortcuts
  install -D -m755 "${srcdir}/ns3.sh" "${pkgdir}/usr/share/ns3/bin/ns3.sh"
  ln -s "/usr/share/ns3/bin/ns3.sh" "${pkgdir}/usr/bin/ns3"
  ln -s "/usr/include/ns3/netanim/NetAnim" "${pkgdir}/usr/bin/netanim"
  install -D -m755 "${srcdir}/NetAnim.desktop" "${pkgdir}/usr/share/applications/NetAnim.desktop"

  # Icons
  install -D -m644 "${srcdir}/netanim/netanim-logo.png" "${pkgdir}/usr/share/pixmaps/netanim-logo.png"

  # Replace each instance of srcdir to correct directory for cmake to work
  find "${pkgdir}/opt/ns3/" -type f -print0 \
    | xargs -0 grep -Il "" \
    | xargs sed -i \
      -e "s,${srcdir}\/brite,\/usr\/include\/ns3\/brite,g" \
      -e "s,${srcdir}\/openflow,\/usr\/include\/ns3\/openflow,g" \
      -e "s,${srcdir}\/click,\/usr\/include\/ns3\/click,g" \
      -e "s,${srcdir},\/opt,g"
}
