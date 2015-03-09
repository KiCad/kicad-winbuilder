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
#     cmake -P GenerateEnvironment.cmake
#
#
# Licence:
#
# Copyright (C) 2011-2013 Brian Sidebotham
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
#
#-------------------------------------------------------------------------------
#
# Version history:
#
#     See CHANGELOG
#

# ------------------------------------------------------------------------------
#
# Minimum cmake version required for this script

cmake_minimum_required(VERSION 2.8.2)

# We need a temporary directory for somewhere to download files to
set( DOWNLOADS_DIR "${CMAKE_SOURCE_DIR}/.downloads" )

# Set the binary directory and make sure it exists
set( BIN_DIR "${CMAKE_SOURCE_DIR}/mingw32/bin" )
file( MAKE_DIRECTORY "${BIN_DIR}" )

# ------------------------------------------------------------------------------
#
# Set a version of cmake to use
#
# NOTE: changing the cmake version means you must also change the same in the
#   KiCadWinbuilder.cmake file too in order that the build environment and build
#   script stay in sync.

set( SEVENZ_URL     http://downloads.sourceforge.net/sevenzip/7za920.zip )
set( SEVENZ_MD5     2fac454a90ae96021f4ffc607d4c00f8 )
set( SEVENZ_FN      7za920.zip )
set( SEVENZ_COMMAND "${BIN_DIR}/7za.exe" )

# CMake Version Information
set( CMAKE_MD5      b1e1256389812ef9e500210a369de31c )
set( CMAKE_FN       cmake-3.1.3-win32-x86.zip )
set( CMAKE_URL      http://www.cmake.org/files/v3.1/${CMAKE_FN} )
set( CMAKE_DIR      ${CMAKE_SOURCE_DIR}/cmake )

# Information regarding Bazaar Download and Installation - Get the URL by using
# wget --no-check-certificate LAUNCH_URL and observe the url similar to below.
# We need to do this in order to get an http:// file served as cmake isn't built
# with ssl support.3
set( BZR_MD5        aa6e8477e0be3c7b4dd0de692068e576 )
set( BZR_FN         bzr-win-zip-2.6b1-1.zip )
set( BZR_URL        http://launchpadlibrarian.net/141517493/${BZR_FN} )
set( BZR_DIR        ${CMAKE_SOURCE_DIR}/bazaar )

# tee so that we can split the stdout and stderr streams into log file and
# console
set( TEE_URL        https://wintee.googlecode.com/files/wtee.exe )
set( TEE_MD5        836bf5c65101a8977b8c1704472c6fcd )
set( TEE_FN         wtee.exe )

# GNUWin32 Patch
set( PATCH_MD5      b9c8b31d62f4b2e4f1887bbb63e8a905 )
set( PATCH_FN       patch-2.5.9-7-bin.zip )
set( PATCH_URL      http://sourceforge.net/projects/gnuwin32/files/patch/2.5.9-7/${PATCH_FN}/download )
set( PATCH_DIR      ${CMAKE_SOURCE_DIR}/patch )

# SWIG Python wrapper
set( SWIG_VER       2.0.10 )
set( SWIG_MD5       cbb7006ecc912f056a2ec7f322fe59fb )
set( SWIG_FN        swigwin-${SWIG_VER}.zip )
set( SWIG_URL       http://prdownloads.sourceforge.net/swig/${SWIG_FN} )
set( SWIG_DIR       ${CMAKE_SOURCE_DIR}/swig )

file( MAKE_DIRECTORY ${BZR_DIR} )
file( MAKE_DIRECTORY ${SWIG_DIR} )
file( MAKE_DIRECTORY ${PATCH_DIR} )

# Download and install an msys MinGW i686 package
macro( download_msys2mingw_package PACKAGE MD5 )
    set( _PKG_URL "http://sourceforge.net/projects/msys2/files/REPOS/MINGW/i686/${PACKAGE}/download" )

    message( STATUS "Downloading ${PACKAGE}" )
    file( DOWNLOAD "${_PKG_URL}" "${DOWNLOADS_DIR}/${PACKAGE}"
          EXPECTED_MD5 "${MD5}"
          STATUS _sts
          LOG lg )

    list( GET _sts 0 sts_code )
    list( GET _sts 1 sts_string )

    if( NOT ${sts_code} EQUAL 0 )
        message( ERROR
            " ${PACKAGE} download FAILED!\n"
            "    URL: ${_PKG_URL}\n"
            "   FILE: ${DOWNLOADS_DIR}/${PACKAGE}\n"
            "   CODE: ${status_code}\n"
            " STRING: ${status_string}\n"
            "    LOG: ${log}\n" )
    endif()

    execute_process(
        COMMAND "${SEVENZ_COMMAND}" x "${DOWNLOADS_DIR}/${PACKAGE}"
        WORKING_DIRECTORY "${DOWNLOADS_DIR}"
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        RESULT_VARIABLE result )

    # Remove the .xz part of the filename because 7-zip extracts the tar from the tar.xz
    string( LENGTH "${PACKAGE}" _FN_LEN )
    math( EXPR _SUBLEN "${_FN_LEN} - 2" )
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

# ------------------------------------------------------------------------------



message( STATUS "Downloading and installing 7zip" )

file( DOWNLOAD "${SEVENZ_URL}" "${DOWNLOADS_DIR}/${SEVENZ_FN}"
        EXPECTED_MD5 "${SEVENZ_MD5}"
        STATUS status
        LOG log )

list( GET status 0 status_code )
list( GET status 1 status_string )

if( NOT ${status_code} EQUAL 0 )

    message( FATAL_ERROR
            " 7-Zip download FAILED!\n"
            "    URL: ${SEVENZ_URL}\n"
            "   FILE: ${DOWNLOADS_DIR}/${SEVENZ_FN}\n"
            "   CODE: ${status_code}\n"
            " STRING: ${status_string}\n"
            "    LOG: ${log}\n" )

endif()

execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xzf "${DOWNLOADS_DIR}/${SEVENZ_FN}"
        WORKING_DIRECTORY "${BIN_DIR}"
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        RESULT_VARIABLE result )

if( NOT ${result} EQUAL 0 )

    message( FATAL_ERROR
            "7-Zip Installation failed!\n"
            "  ERROR: ${error}\n"
            " OUTPUT: ${output}\n" )

endif()

# ------------------------------------------------------------------------------

message( STATUS "Installing MSYS2 MinGW Packages" )

download_msys2mingw_package( mingw-w64-i686-gcc-4.9.2-4-any.pkg.tar.xz
                             b002ad383e0b1ac2a46452c697efa771 )

download_msys2mingw_package( mingw-w64-i686-gcc-libs-4.9.2-4-any.pkg.tar.xz
                             b1af549ebc745c913db34de3436f3749 )

download_msys2mingw_package( mingw-w64-i686-python2-2.7.9-2-any.pkg.tar.xz
                             5da1b0811bc764ae97bb984e1c0d2331 )

download_msys2mingw_package( mingw-w64-i686-wxWidgets-3.0.2-2-any.pkg.tar.xz
                             b418961b7a1d0a758921f6bd31de4f5c )

download_msys2mingw_package( mingw-w64-i686-wxPython-3.0.2.0-1-any.pkg.tar.xz
                             08560d831c578489f3b9c0c670813e18 )

download_msys2mingw_package( mingw-w64-i686-libxml2-2.9.2-5-any.pkg.tar.xz
                             e3b7e54ccdec8027a5f9e414a034d2f0 )

download_msys2mingw_package( mingw-w64-i686-libiconv-1.14-2-any.pkg.tar.xz
                             c295f84ac0682166f1ee39cc61e23ece )

download_msys2mingw_package( mingw-w64-i686-glew-1.12.0-1-any.pkg.tar.xz
                             4620feb7dee5ca3afa89c6e6b18acaac )

download_msys2mingw_package( mingw-w64-i686-cairo-1.14.0-3-any.pkg.tar.xz
                             814b4b5d8bafa0d827eabbf953a730eb )

download_msys2mingw_package( mingw-w64-i686-bzip2-1.0.6-3-any.pkg.tar.xz
                             772f95270db0fb9af5f570b1e88fc407 )

download_msys2mingw_package( mingw-w64-i686-libxslt-1.1.28-4-any.pkg.tar.xz
                             54f38de8a4bffd1ff25bf298cd556788 )

download_msys2mingw_package( mingw-w64-i686-boost-1.57.0-1-any.pkg.tar.xz
                             e266b0828ab0a968f6b6c75e920849ef )

download_msys2mingw_package( mingw-w64-i686-libzip-0.11.2-1-any.pkg.tar.xz
                             bd02c4611b8e42f930848c62842da929 )

# ------------------------------------------------------------------------------
# cmake
message( STATUS "Downloading and installing CMake" )

file( DOWNLOAD ${CMAKE_URL} "${DOWNLOADS_DIR}/${CMAKE_FN}"
        EXPECTED_MD5 ${CMAKE_MD5}
        STATUS status
        LOG log )

list( GET status 0 status_code )
list( GET status 1 status_string )

if( NOT ${status_code} EQUAL 0 )

    message( FATAL_ERROR
            " CMake download FAILED!\n"
            "    URL: ${CMAKE_URL}\n"
            "   FILE: ${DOWNLOADS_DIR}/${CMAKE_FN}\n"
            "   CODE: ${status_code}\n"
            " STRING: ${status_string}\n"
            "    LOG: ${log}\n" )

endif()

# Unzip (install) CMake
execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xzf "${DOWNLOADS_DIR}/${CMAKE_FN}"
        WORKING_DIRECTORY ${CMAKE_DIR}
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        RESULT_VARIABLE result )

if( NOT ${result} EQUAL 0 )

    message( FATAL_ERROR
            "CMake installation failed!\n"
            "  ERROR: ${error}\n"
            " OUTPUT: ${output}\n" )

endif()


# ------------------------------------------------------------------------------
#
message( STATUS "Downloading and installing tee" )

file( DOWNLOAD ${TEE_URL} "${CMAKE_SOURCE_DIR}/mingw32/bin/${TEE_FN}"
        EXPECTED_MD5 ${TEE_MD5}
        STATUS status
        LOG log )

list( GET status 0 status_code )
list( GET status 1 status_string )


# ------------------------------------------------------------------------------
#
message( STATUS "Downloading and installing Bazaar" )

file( DOWNLOAD ${BZR_URL} "${DOWNLOADS_DIR}/${BZR_FN}"
        EXPECTED_MD5 ${BZR_MD5}
        STATUS status
        LOG log )

list( GET status 0 status_code )
list( GET status 1 status_string )

if( NOT ${status_code} EQUAL 0 )

    message( FATAL_ERROR
            " Bazaar download FAILED!\n"
            "    URL: ${BZR_URL}\n"
            "   FILE: ${BZR_DL}\n"
            "   CODE: ${status_code}\n"
            " STRING: ${status_string}\n"
            "    LOG: ${log}\n" )

endif()

# Unzip (install) Bazaar
execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xzf "${DOWNLOADS_DIR}/${BZR_FN}"
        WORKING_DIRECTORY ${BZR_DIR}
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        RESULT_VARIABLE result )

if( NOT ${result} EQUAL 0 )

    message( FATAL_ERROR
            "Bazaar installation failed!\n"
            "  ERROR: ${error}\n"
            " OUTPUT: ${output}\n" )

endif()

# ------------------------------------------------------------------------------
#

message( STATUS "Downloading and installing GNUWin32 Patch" )

file( DOWNLOAD ${PATCH_URL} "${DOWNLOADS_DIR}/${PATCH_FN}"
        EXPECTED_MD5 ${PATCH_MD5}
        STATUS status
        LOG log )

list( GET status 0 status_code )
list( GET status 1 status_string )

if( NOT ${status_code} EQUAL 0 )

    message( FATAL_ERROR
            " GNUWin32 Patch download FAILED!\n"
            "    URL: ${URL_PATCH}\n"
            "   FILE: ${DL_PATCH}\n"
            "   CODE: ${status_code}\n"
            " STRING: ${status_string}\n"
            "    LOG: ${log}\n" )

endif()

# Unzip (install) GNU Patch
execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xzf "${DOWNLOADS_DIR}/${PATCH_FN}"
        WORKING_DIRECTORY ${PATCH_DIR}
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        RESULT_VARIABLE result )

if( NOT ${result} EQUAL 0 )

    message( FATAL_ERROR
            "GNUWin32 Patch installation failed!\n"
            "  ERROR: ${error}\n"
            " OUTPUT: ${output}\n" )

else()

message( STATUS "Installing patch manifest file" )

file( COPY support/patch.exe.manifest
        DESTINATION ${PATCH_DIR}/bin )

endif()


#
# ------------------------------------------------------------------------------
#

message( STATUS "Downloading and Installing SWIG ${SWIG_VER}" )

file( DOWNLOAD ${SWIG_URL} "${DOWNLOADS_DIR}/${SWIG_FN}"
        EXPECTED_MD5 ${SWIG_MD5}
        STATUS status
        LOG log )

list( GET status 0 status_code )
list( GET status 1 status_string )

if( NOT ${status_code} EQUAL 0 )

    message( FATAL_ERROR
            " SWIG ${SWIG_VER} download FAILED!\n"
            "    URL: ${SWIG_URL}\n"
            "   FILE: ${SWIG_DL}\n"
            "   CODE: ${status_code}\n"
            " STRING: ${status_string}\n"
            "    LOG: ${log}\n" )

endif()

# Unzip (install) SWIG
execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xzf "${DOWNLOADS_DIR}/${SWIG_FN}"
        WORKING_DIRECTORY ${SWIG_DIR}
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        RESULT_VARIABLE result )

if( NOT ${result} EQUAL 0 )

    message( FATAL_ERROR
            "SWIG installation failed!\n"
            "  ERROR: ${error}\n"
            " OUTPUT: ${output}\n" )

endif()
