#
# KiCad easy-build script environment builder for Microsoft Windows(tm)
#
# - Cmake
#     Cmake must be installed, and the binaries must be available in the system
#     path
#
#     See: http://www.cmake.org/cmake/resources/software.html
#
# Usage:
#
# Build the KiCad winbuilder environment by running the command line:
#
#     cmake -P KiCad-Winbuilder.cmake
#
# or else on windows you can run
#
#     make*.bat
#
# from this directory
#
#
# Licence:
#
# Copyright (C) 2011-2015 Brian Sidebotham
# Copyright (C) 2015 Nick Østergaard
# Modified 2017 Matthew Swabey
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, you may find one here:
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.html
# or you may search the http://www.gnu.org website for the version 2 license,
# or you may write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
#
#
# Description:
#
# Using only cmake, this script can generate a complete, isolated build
# environment for KiCad Winbuilder
#
# TODO
# * Better handling of the packaged packages output, and remove old pkg.tar.xz
# * In the nsis script, the installer does not install correctly when installing
#   to %PROGRAMFILES%. Seems like it is installed in the VirtualStore and no exe
#   or dll's present. Probably needs raised privileges.
# ------------------------------------------------------------------------------
#
# Minimum cmake version required for this script

cmake_minimum_required( VERSION 2.8.8 )

# We need a temporary directory for somewhere to download files to
set( DOWNLOADS_DIR "${CMAKE_SOURCE_DIR}/.downloads" )
if( NOT EXISTS "${DOWNLOADS_DIR}" )
    file( MAKE_DIRECTORY "${DOWNLOADS_DIR}" )
endif()

set( SUPPORT_DIR "${CMAKE_SOURCE_DIR}/.support" )
if( NOT EXISTS "${SUPPORT_DIR}" )
    file( MAKE_DIRECTORY "${SUPPORT_DIR}" )
endif()

set( LOG_DIR "${CMAKE_SOURCE_DIR}/.logs" )
if( NOT EXISTS "${LOG_DIR}" )
    file( MAKE_DIRECTORY "${LOG_DIR}" )
endif()

set( BIN_DIR "${SUPPORT_DIR}/bin" )
if( NOT EXISTS "${BIN_DIR}" )
    file( MAKE_DIRECTORY "${BIN_DIR}" )
endif()

# Discover if we're on Windows 64-bit or 32-bit to determine which msys to use
set( WINDOWS_DIR $ENV{WINDIR} )
if( EXISTS "${WINDOWS_DIR}/SysWOW64" )
    set( MSYS2 msys64 )
    set( MSYS2_PACKAGE msys2-base-x86_64-20190524.tar.xz )
    set( MSYS2_MD5 b9fddc5a8ea27d5f0eed232795e99725 )
    set( HOST_ARCH x86_64 )
else()
    set( MSYS2 msys32 )
    set( MSYS2_PACKAGE msys2-base-i686-20190524.tar.xz )
    set( MSYS2_MD5 2a663b6a3b9a49a99a32d4a51f8bd613 )
    set( HOST_ARCH i686 )
endif()

# Select the target architecture(s) specified from cmake command...
set( TOOLCHAIN_PACKAGES "" )

if( i686 )
    set( TOOLCHAIN_PACKAGES "${TOOLCHAIN_PACKAGES} mingw-w64-i686-toolchain mingw-w64-i686-boost mingw-w64-i686-cairo mingw-w64-i686-curl mingw-w64-i686-glew mingw-w64-i686-openssl mingw-w64-i686-wxPython mingw-w64-i686-wxWidgets mingw-w64-i686-cmake mingw-w64-i686-gcc mingw-w64-i686-python2 mingw-w64-i686-python2-pip mingw-w64-i686-pkg-config mingw-w64-i686-swig mingw-w64-i686-libxslt git doxygen" )
endif()

if( x86_64 )
    set( TOOLCHAIN_PACKAGES "${TOOLCHAIN_PACKAGES} mingw-w64-x86_64-toolchain mingw-w64-x86_64-boost mingw-w64-x86_64-cairo mingw-w64-x86_64-curl mingw-w64-x86_64-glew mingw-w64-x86_64-openssl mingw-w64-x86_64-wxPython mingw-w64-x86_64-wxWidgets mingw-w64-x86_64-cmake mingw-w64-x86_64-gcc mingw-w64-x86_64-python2 mingw-w64-x86_64-python2-pip mingw-w64-x86_64-pkg-config mingw-w64-x86_64-swig mingw-w64-x86_64-libxslt git doxygen" )
endif()

# Test the existence of a file and verifiy its MD5 against a supplied one. 
#    Success signalled by setting variable, name passed as TEST, to TRUE
#    Upon MD5 failure delete file that fails hash.
function( test_file TEST FILE_PATH MD5 )
    set( ${TEST} "FALSE" )

    if( NOT EXISTS "${FILE_PATH}" )
        return()
    endif()

    file (MD5 ${FILE_PATH} _FILE_MD5)
    if (NOT ${_FILE_MD5} EQUAL ${MD5} )
        file(REMOVE ${FILE_PATH} )
        return()
    endif()
    set( ${TEST} "TRUE" )
endfunction()

# Download and install an msys MinGW i686 package
macro( download_msys2mingw_base_package PACKAGE MD5 )

    # Don't repeat things when building the build environment
    set(TEST "FALSE")
    test_file( TEST "${DOWNLOADS_DIR}/${PACKAGE}" ${MD5} )
    if( NOT ${TEST} )

        set( _PKG_URL "http://repo.msys2.org/distrib/${HOST_ARCH}/${PACKAGE}" )

        message( STATUS "Downloading ${PACKAGE}" )
        file( DOWNLOAD "${_PKG_URL}" "${DOWNLOADS_DIR}/${PACKAGE}"
              EXPECTED_MD5 "${MD5}"
              STATUS _sts
              LOG lg
              SHOW_PROGRESS )

        list( GET _sts 0 sts_code )
        list( GET _sts 1 sts_string )

        if( NOT ${sts_code} EQUAL 0 )
	    message( FATAL_ERROR
                " ${PACKAGE} download FAILED!\n"
                "    URL: ${_PKG_URL}\n"
                "   FILE: ${DOWNLOADS_DIR}/${PACKAGE}\n"
                "   CODE: ${status_code}\n"
                " STRING: ${status_string}\n"
                "    LOG: ${log}\n" )
        endif()
    endif()

    execute_process(
        COMMAND "${SEVENZ_COMMAND}" x "${DOWNLOADS_DIR}/${PACKAGE}" "-y"
        WORKING_DIRECTORY "${DOWNLOADS_DIR}"
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        RESULT_VARIABLE result )

    if( NOT ${result} EQUAL 0 )
        message( STATUS "7z result ${result}" )
        message( STATUS "7z output ${output}" )
        message( STATUS "7z error ${error}" )
    endif()

    # Remove the .xz part of the filename because 7-zip extracts the tar from the tar.xz
    string( LENGTH "${PACKAGE}" _FN_LEN )
    math( EXPR _SUBLEN "${_FN_LEN} - 3" )
    string( SUBSTRING "${PACKAGE}" 0 ${_SUBLEN} _TAR_FN )

    # Now use Cmake's internal tar implementation to extract mingw-w64
    execute_process(
        COMMAND "${CMAKE_COMMAND}" -E tar xf "${DOWNLOADS_DIR}/${_TAR_FN}"
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        RESULT_VARIABLE result )

    if( NOT ${result} EQUAL 0 )
        message( FATAL_ERROR
            " ${PACKAGE} extraction FAILED!\n"
            "  ERROR: ${error}\n"
            " OUTPUT: ${output}\n" )

    endif()
endmacro()

macro( download_and_install URL MD5 FN WD )
    set(TEST "FALSE")
    test_file( TEST "${DOWNLOADS_DIR}/${FN}" ${MD5} )
    if( NOT ${TEST} )
        message( STATUS "Downloading and installing ${FN}" )

        file( DOWNLOAD "${URL}" "${DOWNLOADS_DIR}/${FN}"
                EXPECTED_MD5 "${MD5}"
                STATUS status
                LOG log )

        list( GET status 0 status_code )
        list( GET status 1 status_string )

        if( NOT ${status_code} EQUAL 0 )
            message( FATAL_ERROR
                    " ${FN} download FAILED!\n"
                    "    URL: ${URL}\n"
                    "   CODE: ${status_code}\n"
                    " STRING: ${status_string}\n"
                    "    LOG: ${log}\n" )
        endif()
    endif()

    # If the download is a zip file...
    execute_process(
            COMMAND ${CMAKE_COMMAND} -E tar xzf "${DOWNLOADS_DIR}/${FN}"
            WORKING_DIRECTORY "${WD}"
            OUTPUT_VARIABLE output
            ERROR_VARIABLE error
            RESULT_VARIABLE result )

    if( NOT ${result} EQUAL 0 )
        message( FATAL_ERROR
                "${FN} Installation failed!\n"
                "  ERROR: ${error}\n"
                " OUTPUT: ${output}\n" )
    endif()
endmacro()

# ------------------------------------------------------------------------------

# We need 7-zip in order to extract MSYS2 packages without requiring 7z to be required.
set( SEVENZ_URL     http://downloads.sourceforge.net/sevenzip/7za920.zip )
set( SEVENZ_MD5     2fac454a90ae96021f4ffc607d4c00f8 )
set( SEVENZ_FN      7za920.zip )
set( SEVENZ_COMMAND "${BIN_DIR}/7za.exe" )

if( NOT EXISTS "${SEVENZ_COMMAND}" )
    download_and_install( "${SEVENZ_URL}" "${SEVENZ_MD5}" "${SEVENZ_FN}" "${BIN_DIR}" )
endif()

# ------------------------------------------------------------------------------

set( NSIS_URL https://sourceforge.net/projects/nsis/files/NSIS%203/3.03/nsis-3.03.zip/download )
set( NSIS_MD5 d4919dc089ec256a7264e97ada299b64 )
set( NSIS_FN nsis-3.03.zip )
set( NSIS_MAKE_COMMAND "${SUPPORT_DIR}/nsis-3.03/Bin/makensis.exe" )

if( NOT EXISTS "${NSIS_MAKE_COMMAND}" )
    download_and_install( "${NSIS_URL}" "${NSIS_MD5}" "${NSIS_FN}" "${SUPPORT_DIR}" )
endif()

# ------------------------------------------------------------------------------

if( NOT EXISTS "${CMAKE_SOURCE_DIR}/${MSYS2}/msys2.ini" )
    file( REMOVE_RECURSE "${CMAKE_SOURCE_DIR}/${MSYS2}" )

    message( STATUS "Installing MSYS2 Base" )
    download_msys2mingw_base_package( ${MSYS2_PACKAGE} ${MSYS2_MD5} )

endif()

macro( execute_msys2_bash CMD LOG )
    message( STATUS "Running ${CMD}" )

    file( WRITE "${CMAKE_SOURCE_DIR}/${MSYS2}/tmp/last_error" "${CMD}\n" )
    execute_process(
        COMMAND "${CMAKE_SOURCE_DIR}/${MSYS2}/usr/bin/bash.exe" -l -c "set -o pipefail; ${CMD} 2>&1 | tee -a /tmp/last_error" 
	RESULT_VARIABLE RESULT )

    # UNIX commands return 0 on success while CMake treats 0 as a fail. So test for 0 success!
    if( ${RESULT} EQUAL 0 )
	    file( RENAME "${CMAKE_SOURCE_DIR}/${MSYS2}/tmp/last_error" ${LOG} )
	    message ( STATUS "Success ${RESULT}: ${CMD}" )
    else()
	    file( COPY "${CMAKE_SOURCE_DIR}/${MSYS2}/tmp/last_error" DESTINATION ${LOG_DIR} )
	    message( FATAL_ERROR "Error running ${CMD}\n Output in: ${LOG_DIR}/last_error" )
    endif()

endmacro()

# According to section III of http://sourceforge.net/p/msys2/wiki/MSYS2%20installation/
# we should:

if( NOT EXISTS "${LOG_DIR}/pacman_initial" )
    execute_msys2_bash( "pacman --noconfirm -Sy" "${LOG_DIR}/pacman_initial" )
    execute_msys2_bash( "pacman --noconfirm --needed -S bash pacman pacman-mirrors msys2-runtime" "${LOG_DIR}/pacman_bash" )
    execute_msys2_bash( "pacman --noconfirm --needed -S p11-kit" "${LOG_DIR}/pacman_bash_p11-kit" )
    execute_msys2_bash( "pacman --noconfirm --needed -S ca-certificates" "${LOG_DIR}/pacman_bash2" )

    # if using msys 32-bit (apparently not required for 64-bit)
    if( "${MSYS2}" STREQUAL "msys32" )
        execute_process(
            COMMAND "${CMAKE_SOURCE_DIR}/${MSYS2}/autorebase.bat" 2>&1
            COMMAND "${TEE_COMMAND}" "${LOGDIR}/autorebase" )
    endif()

    # Final update and then we're ready to use msys2...
    execute_msys2_bash( "pacman --noconfirm -Su" "${LOG_DIR}/pacman_update" )
endif()

if( NOT EXISTS "${LOG_DIR}/pacman_required_packages" )
    # Get the initial required packages and then update pacman again
    execute_msys2_bash( "pacman --noconfirm -S base-devel" "${LOG_DIR}/pacman_base_devel" )
    execute_msys2_bash( "pacman --noconfirm -S git make ${TOOLCHAIN_PACKAGES}" "${LOG_DIR}/pacman_required_packages" )
    execute_msys2_bash( "pacman --noconfirm -Su" "${LOG_DIR}/pacman_required_packages_update" )
endif()

# Get the MinGW packages source from github so we can get the official MSYS2
# KiCad pacman package source
# Get the home directory
file( GLOB HOME_DIR "${CMAKE_SOURCE_DIR}/${MSYS2}/home/*" )
if ( "${HOME_DIR}" STREQUAL "" )
    set( HOME_DIR "${CMAKE_SOURCE_DIR}/${MSYS2}/home/user" )
    file( MAKE_DIRECTORY "${HOME_DIR}" )
endif()
set( KICAD_PACKAGE_SOURCE_DIR "${HOME_DIR}/MINGW-packages/mingw-w64-kicad-git/" )
message( STATUS "HOME_DIR ${HOME_DIR}" )
message( STATUS "KICAD_PACKAGE_SOURCE_DIR ${KICAD_PACKAGE_SOURCE_DIR}" )
get_filename_component( USERNAME "${HOME_DIR}" NAME )
message( STATUS "MSYS2 user name is: $USERNAME=${USERNAME}" )

# Get the MinGW packages project for MSYS2
if( NOT EXISTS "${HOME_DIR}/MINGW-packages" )
    execute_msys2_bash( "cd \"${HOME_DIR}\" && git clone https://github.com/Alexpux/MINGW-packages.git" "${LOG_DIR}/git_clone" )
endif()

set( EXPORT_CARCH "" )
if( i686 AND NOT x86_64 )
    set( EXPORT_CARCH "export CARCH=i686 &&" )
elseif( NOT i686 AND x86_64 )
    set( EXPORT_CARCH "export CARCH=x86_64 &&" )
endif()

# Copy proper PKGBUILD (without bzr docs!)
file( COPY "${CMAKE_SOURCE_DIR}/PKGBUILD" DESTINATION "${HOME_DIR}/MINGW-packages/mingw-w64-kicad-git" )

# Actually build KiCad
execute_msys2_bash( "cd \"${HOME_DIR}/MINGW-packages/mingw-w64-kicad-git\" && ${EXPORT_CARCH} TERM=vt220 makepkg-mingw -s --noconfirm" "${LOG_DIR}/makepkg" )

# Copy the runtime helper script to the MSYS2 system
file( COPY "${CMAKE_SOURCE_DIR}/copydlls.sh" DESTINATION "${HOME_DIR}/" )

# Run through the installer process for each architecture
if( EXISTS "${KICAD_PACKAGE_SOURCE_DIR}/pkg/mingw-w64-i686-kicad-git/mingw32" AND i686 )
#    file( COPY "${KICAD_PACKAGE_SOURCE_DIR}/src/kicad/packaging/windows/nsis"
    file( COPY "${CMAKE_SOURCE_DIR}/nsis"
          DESTINATION "${HOME_DIR}" )

    # Copy the runtime requirements (shared objects mainly)
    execute_msys2_bash( "$HOME/copydlls.sh \
                         --arch=i686 \
                         --pkgpath=$HOME/MINGW-packages/mingw-w64-kicad-git \
                         --nsispath=$HOME/nsis \
                         --makensis=${NSIS_MAKE_COMMAND}"
                         "${LOG_DIR}/copydlls_mingw32" )
endif()

if( EXISTS "${KICAD_PACKAGE_SOURCE_DIR}/pkg/mingw-w64-x86_64-kicad-git/mingw64" AND x86_64 )
#    file( COPY "${KICAD_PACKAGE_SOURCE_DIR}/src/kicad/packaging/windows/nsis"
    file( COPY "${CMAKE_SOURCE_DIR}/nsis"
          DESTINATION "${HOME_DIR}" )

    # Copy the runtime requirements (shared objects mainly)
    execute_msys2_bash( "~/copydlls.sh \
                         --arch=x86_64 \
                         --pkgpath=\$HOME/MINGW-packages/mingw-w64-kicad-git \
                         --nsispath=$HOME/nsis \
                         --makensis=${NSIS_MAKE_COMMAND}"
                         "${LOG_DIR}/copydlls_mingw64" )
endif()

