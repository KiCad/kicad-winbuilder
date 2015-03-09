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

# We need 7-zip in order to extract the MSYS2 package

set( SEVENZ_URL     http://downloads.sourceforge.net/sevenzip/7za920.zip )
set( SEVENZ_MD5     2fac454a90ae96021f4ffc607d4c00f8 )
set( SEVENZ_FN      7za920.zip )
set( SEVENZ_COMMAND "${BIN_DIR}/7za.exe" )


# Download and install an msys MinGW i686 package
macro( download_msys2mingw_package PACKAGE MD5 )

    # Don't repeat things when building the build environment
    if( NOT EXISTS "${DOWNLOADS_DIR}/${PACKAGE}" )

        set( _PKG_URL "http://sourceforge.net/projects/msys2/files/Base/i686/${PACKAGE}/download" )
        #set( _PKG_URL "http://sourceforge.net/projects/msys2/files/REPOS/MINGW/i686/${PACKAGE}/download" )

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

message( STATUS "Installing MSYS2" )

download_msys2mingw_package( msys2-base-i686-20150202.tar.xz
                             cf6c40b999a8d20085a18eb64c51c99f )

return()

# See https://github.com/Alexpux/MSYS2-packages/blob/master/msys2-installer/make-msys2-installer.bat
# for setup information

message( STATUS "Running pacman... ${CMAKE_CURRENT_SOURCE_DIR}/msys32/usr/bin/bash.exe" )
execute_process( COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/msys32/usr/bin/bash.exe -l -c "pacman --needed --noconfirm -Sy bash pacman pacman-mirrors msys2-runtime"
    RESULT_VARIABLE _PAC_RESULT
    ERROR_VARIABLE _PAC_ERROR
    OUTPUT_VARIABLE _PAC_OUTPUT )

message( STATUS "Running pacman... ${CMAKE_CURRENT_SOURCE_DIR}/msys32/usr/bin/bash.exe" )
execute_process( COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/msys32/usr/bin/bash.exe -l -c "pacman --needed --noconfirm -Sy bash pacman pacman-mirrors msys2-runtime"
    RESULT_VARIABLE _PAC_RESULT
    ERROR_VARIABLE _PAC_ERROR
    OUTPUT_VARIABLE _PAC_OUTPUT )

message( STATUS "Result: ${_PAC_RESULT}\nError: ${_PAC_ERROR}\nOutput${_PAC_OUTPUT}\n" )

message( STATUS "Running pacman.... ${CMAKE_CURRENT_SOURCE_DIR}/msys32/usr/bin/bash.exe" )
execute_process( COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/msys32/usr/bin/bash.exe -l -c "pacman -Syu git --noconfirm"
    RESULT_VARIABLE _PAC_RESULT
    ERROR_VARIABLE _PAC_ERROR
    OUTPUT_VARIABLE _PAC_OUTPUT )

message( STATUS "Result: ${_PAC_RESULT}\nError: ${_PAC_ERROR}\nOutput${_PAC_OUTPUT}\n" )