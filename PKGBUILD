# Maintainer: Alexey Pavlov <alexpux@gmail.com>

_realname=kicad
pkgname="${MINGW_PACKAGE_PREFIX}-${_realname}-git"
pkgver=r5762.d3b3131
pkgrel=1
pkgdesc="Software for the creation of electronic schematic diagrams and printed circuit board artwork"
arch=('any')
url="http://www.kicad-pcb.org"
license=("GPL2+")
provides=("${MINGW_PACKAGE_PREFIX}-${_realname}")
conflicts=("${MINGW_PACKAGE_PREFIX}-${_realname}")
depends=("${MINGW_PACKAGE_PREFIX}-boost"
        "${MINGW_PACKAGE_PREFIX}-cairo"
        "${MINGW_PACKAGE_PREFIX}-glew"
        "${MINGW_PACKAGE_PREFIX}-openssl"
        "${MINGW_PACKAGE_PREFIX}-wxPython"
        "${MINGW_PACKAGE_PREFIX}-wxWidgets")
makedepends=("${MINGW_PACKAGE_PREFIX}-cmake"
             "${MINGW_PACKAGE_PREFIX}-gcc"
             "${MINGW_PACKAGE_PREFIX}-python2"
             "${MINGW_PACKAGE_PREFIX}-pkg-config"
             "${MINGW_PACKAGE_PREFIX}-swig"
             "bzr"
             "git"
             "doxygen")
source=("${_realname}"::"git+https://github.com/KiCad/kicad-source-mirror.git"
        #"${_realname}-docs"::"bzr+https://code.launchpad.net/~kicad-developers/kicad/doc"
        "${_realname}-docs"::"git+https://github.com/blairbonnett-mirrors/kicad-doc.git"
        "${_realname}-libs"::"git+https://github.com/KiCad/kicad-library.git"
       )
md5sums=('SKIP'
         'SKIP'
         'SKIP'
        )

_builddir="build-${MINGW_CHOST}"

pkgver() {
  cd "$srcdir/$_realname"
  printf "r%s.%s" "$(git rev-list --count --first-parent HEAD)" "$(git rev-parse --short HEAD)"
}

prepare() {
  cd "$srcdir/$_realname"
  msg2 "Cleaning old files not known by git..."
  git checkout -- .
  msg2 "Patching..."
  echo ${_builddir}
  pwd
  # ${_builddir}/CMakeLists.txt.orig ${_builddir}
  #cat ${srcdir}/kicad/CMakeModules/CreateGitVersionHeader.cmake
  if [ -e ${srcdir}/kicad/CMakeModules/CreateGitVersionHeader.cmake ]; then
    echo "DELETING"
    rm ${srcdir}/kicad/CMakeModules/CreateGitVersionHeader.cmake
  fi
  patch -p1 -i ../../git-cmake-version-v2.patch
}

build() {
  cd "$srcdir"
  msg2 "Configuring KiCad"
  if [ -d ${_builddir} ]; then
    cd ${_builddir}
  else
    mkdir ${_builddir}; cd ${_builddir}
  fi
  pwd
  ${MINGW_PREFIX}/bin/cmake.exe \
    -G"MSYS Makefiles" \
    -DCMAKE_PREFIX_PATH=${MINGW_PREFIX} \
    -DCMAKE_INSTALL_PREFIX=${pkgdir}${MINGW_PREFIX} \
    -DOPENSSL_ROOT_DIR=${MINGW_PREFIX} \
    -DKICAD_SKIP_BOOST=ON \
    -DKICAD_SCRIPTING=ON \
    -DKICAD_SCRIPTING_MODULES=ON \
    -DKICAD_SCRIPTING_WXPYTHON=ON \
    -DPYTHON_EXECUTABLE=${MINGW_PREFIX}/bin/python2.exe \
    ../${_realname}

  make -j4

  cd ${srcdir}
  msg2 "Configure the documentation installation build"
  [[ -d build-docs ]] && rm -r build-docs
  mkdir build-docs && cd build-docs
  ${MINGW_PREFIX}/bin/cmake.exe \
    -G "MSYS Makefiles" \
    -DCMAKE_INSTALL_PREFIX=${pkgdir}${MINGW_PREFIX} \
    ../${_realname}-docs

  cd ${srcdir}
  msg2 "Configure the library installation build"
  [[ -d build-libs ]] && rm -r build-libs
  mkdir build-libs && cd build-libs
  ${MINGW_PREFIX}/bin/cmake.exe \
    -G "MSYS Makefiles" \
    -DCMAKE_INSTALL_PREFIX=${pkgdir}${MINGW_PREFIX} \
    ../${_realname}-libs
}

package() {
  msg2 "Installing KiCad"
  cd ${srcdir}/${_builddir}
  make install

  cd ${srcdir}
  msg2 "Installing KiCad documentation"
  pwd
  
  cd build-docs
  make install

  cd ${srcdir}
  pwd
  msg2 "Installing KiCad libraries"
  cd build-libs
  make install
}
