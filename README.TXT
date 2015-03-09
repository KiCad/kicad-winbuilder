
    Part of the KiCad-Winbuilder project

Licence:

    Copyright (C) 2011-2013 Brian Sidebotham

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, you may find one here:
    http://www.gnu.org/licenses/old-licenses/gpl-2.0.html
    or you may search the http://www.gnu.org website for the version 2 license,
    or you may write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

Homepage of the project:
    http://www.valvers.com/open-software/projects/kicad-winbuilder

Launchpad home:
    https://launchpad.net/kicad-winbuilder

Project:
    KiCad easy-build script for Microsoft Windows XP, Vista, 7 x32 + x64

Dependencies:

NOTE: If you are using a binary release there are no dependencies as the build
   tools are already supplied

If you are using KiCad-Winbuilder from source, you only need CMake in order to
generate the build environment (See Usage)

- Bazaar
    Bazaar version control system must be installed, and the binaries must be
    available in the windows path. It is recommended to get the standalone
    installation.

    See: http://wiki.bazaar.canonical.com/WindowsDownloads

- Cmake
    Cmake must be installed, and the binaries must be available in the system
    path

    See: http://www.cmake.org/cmake/resources/software.html


Usage:

1 - Download a binary release, and type:

    make.bat

2 - If you're interested in developing or using KiCad-Winbuilder from source
    you can checkout the source for KiCad-Winbuilder and then enter the /env
    directory and type:

    make.bat

    to generate the build environment, and then continue with method #1


Description:

Apart from the above dependencies which are required to be installed prior to
running this script, all other dependencies for building KiCad are downloaded
and installed by this script. This includes the GCC compiler suite, wxPython
and the KiCad source code.

