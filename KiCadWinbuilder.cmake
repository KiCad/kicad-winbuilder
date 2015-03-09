#
#
# Part of the KiCad-Winbuilder project
#
# Licence:
#
# Copyright (C) 2011-2014 Brian Sidebotham
# Copyrighr (C) 2013 Maciej Sumiński
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
#-------------------------------------------------------------------------------


# Minimum cmake version required for this script
cmake_minimum_required(VERSION 2.8.2)
include( ProcessorCount )

# Set the build type.
# Valid settings are: "Release" or "Debug"
set( BUILD "Release" )

# If you've had trouble building and repository has not changed, you can set
# this to on in order to force a build even though the code is already
# up-to-date
set( FORCEBUILD ON )

# Set to on to build with Python scripting support
set( SCRIPTING ON )

# Set to on if you want to trial the new GITHUB_PLUGIN
set( BUILD_GITHUB_PLUGIN ON )

# Set to on if you want to use parallel processes to build, generates high
# CPU and memory usage. Set to OFF if you're having problems with memory
# usage or too much CPU usage
set( PARALLEL_BUILD ON )

# Set this to on if you also want to have the latest (BZR Head) documentation
set( DOCUMENTATION ON )

# Set this to on if you also want to have the latest (BZR Head) library
set( LIBRARY ON )

# Set this to on if you want to see the build output on the console (it's very
# noisy when building boost, but apart from that it's pretty useful!)
set( PROGRESS ON )

# Only set this to off if you're repeating builds often and you're confident
# nothing has changed in the PCBNEW python API
set( CLEAN_PCBNEW_PYTHON_FILES ON )

# ----------------------------------------------------------------------------

# Set the Version number for this script
set( WINBUILDER_VERSION 3.4 )
message( STATUS "KiCad-Winbuilder V${WINBUILDER_VERSION}" )

# Set the kicad root dir - we can install things here to be searched by CMake's
# find*.cmake modules. Useful for installing pre-requisites
set( KICADDIR   "${CMAKE_SOURCE_DIR}/kicad" )

# Set a bin directory to populate on successful build
set( BINDIR     "${KICADDIR}/bin" )

# Set a place to put the shared files for the KiCad install ( Templates and
# libraries )
set( SHAREDIR   "${KICADDIR}/share" )

# Set a place to put the latest documentation
set( DOCDIR     "${KICADDIR}/doc" )

# Setup variables for a list of directories
set( LOGDIR     "${CMAKE_SOURCE_DIR}/logs" )

# Set a build directory will have release/debug subdirs
set( BUILDDIR   "${CMAKE_SOURCE_DIR}/build" )

# The source code directory
set( SRCDIR     "${CMAKE_SOURCE_DIR}/src" )

# The KiCad-Winbuilder environment directory
set( ENVDIR     "${CMAKE_SOURCE_DIR}/env" )

# Set the library zip url
set( LIBURL https://github.com/KiCad/kicad-library/archive/master.zip )
set( LIBDL  "${SRCDIR}/kicad-library-master.zip" )

# Setup the version of wxPython to use
set( WXVER  3.0.0 )
set( WXFILE "wxPython-cmake-mswu-gcc_dll_cm-${WXVER}-win32" )
set( WXURL  "https://launchpad.net/wxwidgets-cmake/wxpython-3/wxpython-3.0.0-0/+download/wxPython-cmake-mswu-gcc_dll_cm-3.0.0-win32.zip" )
set( WXMD5  b40cd94f27412562cf6322a32760557a )
set( WXROOT "${BUILDDIR}/${WXFILE}" )
set( WXDL   "${BUILDDIR}/${WXFILE}.zip" )

# Setup the version of GLEW to use
set( GLEWBZR  "lp:glew-cmake" )
set( GLEWROOT "${SRCDIR}/glew-cmake" )
set( ENV{GLEW_ROOT_PATH} "${GLEWROOT}" )

# BZIP2 is required for compilation - Download, patch on CMakeLists.txt and build
set( BZ2VER     1.0.6 )
set( BZ2FILE    "bzip2-${BZ2VER}.tar.gz" )
set( BZ2URL     "http://www.bzip.org/${BZ2VER}/${BZ2FILE}" )
set( BZ2MD5     00b516f4704d4a7cb50a1d97e6e8e15b )
set( BZ2SRC     "${SRCDIR}/bzip2" )
set( BZ2ROOT    "${SRCDIR}/bzip2/bzip2-${BZ2VER}" )

# Setup the version of Cairo to use
set( CAIROVER  1.10.2-2 )
set( CAIROURL  "http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/cairo-dev_${CAIROVER}_win32.zip" )
set( CAIROMD5  "a05dd48e21e0161d67f5eab640e7c040" )
set( CAIROROOT "${SRCDIR}/cairo/cairo-${CAIROVER}" )
set( CAIRODL   "cairo-dev_${CAIROVER}_win32.zip" )
set( ENV{CAIRO} "${CAIROROOT}" )

# Set the tee command for splitting the stream to console and file
set( TEE_COMMAND ${ENVDIR}/tee/wtee.exe )

# Set the number of build jobs, use a number suitable for this PC
# Use the rather traditional n-1 job count so that the user can still get
# on with other tasks whilst building this project.
#
# Do not use parallel jobs until specctra_keywords.cpp has been generated
# because doing so can cause this file to be corrupt when generated during
# a parallel job build

set( N 0 )

if( PARALLEL_BUILD )
    ProcessorCount( N )
    if( N GREATER 1 )
        math( EXPR N "${N} - 1" )
    endif()
endif()

if( ${N} GREATER 1 )
    message( STATUS "Parallel build using ${N} Processors" )
    set( MAKE_KI_OPTS "-j${N}" )
endif()

# Create a directory to place log files in
if( NOT EXISTS "${LOGDIR}" )
    file( MAKE_DIRECTORY "${LOGDIR}" )
endif()

# Create a directory to place log files in
if( NOT EXISTS "${BINDIR}" )
    file( MAKE_DIRECTORY "${BINDIR}" )
endif()

if( NOT EXISTS "${SRCDIR}" )
    file( MAKE_DIRECTORY "${SRCDIR}" )
endif()

set( OLD_PATH $ENV{PATH} )
set( MINGW_MAKE mingw32-make )
set( GCC gcc )

# Check the installation path length
set( MAX_INSTALLLENGTH  35 )
string( LENGTH "${CMAKE_SOURCE_DIR}" INSTALLLENGTH )
if( INSTALLLENGTH GREATER MAX_INSTALLLENGTH )
    message( WARNING "Your install path maybe too long "
                     "to be able to successfully build KiCad. "
                     "Try re-installing to a root directory "
                     "if the build fails!" )
endif()

# ----------------------------------------------------------------------------
# Check that this is the latest version of the script. Otherwise print a
# message to let the user know that their build is out of date

message( STATUS "Build type: ${BUILD}" )

file( DOWNLOAD
        "http://www.valvers.com/files/KICAD_WINBUILDER_LATEST_VERSION.TXT"
        "${SRCDIR}/LATEST_VERSION"
        STATUS download_error_list )

# Check the filesize. Sometimes the download doesn't fail and file exists, but
# no data has been downloaded. Usually when you're behind a proxy.
set( LATEST_VERSION_SIZE 0 )
if( EXISTS "${SRCDIR}/LATEST_VERSION" )
    file( READ "${SRCDIR}/LATEST_VERSION" LATEST_VERSION LIMIT 3 )
    string( LENGTH "${LATEST_VERSION}" LATEST_VERSION_SIZE )
endif()

list( GET ${download_error_list} 0 download_error )
list( GET ${download_error_list} 1 download_error_str )

if( ${download_error} OR ${LATEST_VERSION_SIZE} LESS 3 )

    set( error "" )
    set( error_str "" )

    if( ${download_error} )
        set( error ${download_error} )
    endif()

    if( ${download_error_str} )
        set( error ${download_error_str} )
    endif()

    message( ERROR "${error} Couldn't check to see if there's a new"
        " KiCad-Winbuilder version!\n"
        "${error_str}" )

else()

    if( ${LATEST_VERSION} VERSION_GREATER ${WINBUILDER_VERSION} )

        message( STATUS "There is a new version of KiCad-Winbuilder. You "
            "should get the latest version at your earliest convienience" )

        file( READ "${SRCDIR}/LATEST_VERSION" NEW_VERSION_INFORMATION )
        message( STATUS "Latest version details: ${NEW_VERSION_INFORMATION}" )

    endif()

endif()


#-----------------------------------------------------------------------------
#
# Check Environment Issues
#
message( STATUS "Checking for environment problems" )

execute_process(
    COMMAND sh --version
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE sh_stdout
    ERROR_VARIABLE sh_stderr
    RESULT_VARIABLE sh_NOT_FOUND )

if( NOT sh_NOT_FOUND )

    message( ERROR "  sh (MSYS Shell) is in your path. This prevents MinGW "
        " from working correctly. It's possible that instead "
        " of having MSYS installed, you have WinAVR installed "
        " instead, which includes sh too.\n"
        "\n"
        " Remove sh from your path by temporarily renaming the "
        " directory where it is located and then re-run this "
        " script." )

    return()

endif()

#-------------------------------------------------------------------------------
#
# Check Bazaar installation
#
message( STATUS "Checking for installed Bazaar" )
execute_process(
    COMMAND cmd /c bzr
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE bzr_stdout
    RESULT_VARIABLE bzr_NOT_FOUND )

#
# Error when bazaar is not available
#
if( bzr_NOT_FOUND )

    message( ERROR "Bazaar must be installed and in the windows path" )
    message( ERROR "See: http://wiki.bazaar.canonical.com/WindowsDownloads" )
    return()

else()

    # Test to see if bzr has been correctly configured yet. If not, we will
    # need to guide the user to set it up
    execute_process(
        COMMAND cmd /c bzr whoami
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        OUTPUT_VARIABLE bzr_stdout
        ERROR_VARIABLE bzr_stderr
        RESULT_VARIABLE bzr_NOT_SETUP )

    # Barf and return if Bazaar has not yet been setup correctly
    if( bzr_NOT_SETUP )

        message( ERROR
            " Bazaar has not yet been setup. You must tell the Bazaar install\n"
            " who you are by supplying an email address. Just following the  \n"
            " instructions given by Bazaar below:\n"
            " \n"
            "${bzr_stderr}")
        return()

    endif()

endif()

#-------------------------------------------------------------------------------
#
# Check the compiler is working properly. The gcc compiler is included with the
# KiCad-Winbuilder install - this should never fail.
#

execute_process(
    COMMAND gcc -dumpversion
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE mingw_stdout
    ERROR_VARIABLE mingw_stderr
    RESULT_VARIABLE mingw_NOT_FOUND
    OUTPUT_STRIP_TRAILING_WHITESPACE )

#-------------------------------------------------------------------------------
# Carry on searching if there was no installed MinGW compiler installed

if( mingw_NOT_FOUND )

	message( FATAL_ERROR "gcc compiler not working!" )
	return()

endif()


#-------------------------------------------------------------------------------
#
# Check for installed wxPython
#
message( STATUS "Checking for wxPython" )

# Try to find wxPython and when found set this to true
set( wxPython_FOUND false )

if( EXISTS "${WXROOT}/lib/gcc_dll/wxbase300u_gcc_cm.dll" )
	set( wxPython_FOUND true )
endif()

#
# If wxPython cannot be found, download the pre-built (for KiCad) wxPython
# binaries
#

if( NOT wxPython_FOUND )

    # Check that the pre-built wxPython for KiCad has been downloaded

    if( NOT EXISTS "${WXDL}" )

        message( STATUS "Downloading wxPython" )

        file( DOWNLOAD ${WXURL} ${WXDL}
            EXPECTED_MD5 ${WXMD5}
            STATUS download_error_list )

        list( GET ${download_error_list} 0 download_error )
        list( GET ${download_error_list} 1 download_error_str )

    endif()

    # Report an error on failure and quit the script as there is nothing else
    # left to do

    if( download_error )

        message( ERROR "${download_error} Failed to download wxPython-${WXVER}" )
        message( ERROR "${download_error_str}" )
        return()

    endif()

    # See if we need to decompress the archive, or if it has already been
    # decompressed

    # Set the error flag used below to zero to begin with
    SET( error 0 )

    # Check for the existence of the makefile we'll be using later to build the
    # source
    if( NOT EXISTS "${WXROOT}/include" )

        message( STATUS "Decompressing wxPython" )

        execute_process(
            COMMAND ${CMAKE_COMMAND} -E tar xzf ${WXDL}
            WORKING_DIRECTORY ${BUILDDIR}
            RESULT_VARIABLE untar_error )

        # Because of a bug in CMake, the tar execution runs without failure if
        # the archive is of zero length. This happens when a file is
		# incorrectly downloaded. We need to test for this separately.
        file( READ ${WXDL} wx_size LIMIT 2 )

        if( NOT wx_size )
            SET( untar_error 1 )
        endif()

    endif()


    # Report an error on failure and quit the script as there is nothing else
    # left to do
    if( untar_error )

        message( ERROR "  ${untar_error} " )
        message( ERROR "  Failed to decompress wxPython. Please" )
        message( ERROR "  run this script again to re-try downloading" )

        # If we failed to decompress wxPython delete the file in case it was
        # corrupt after a download attempt failed
        message( STATUS "Removing ${WXDL}" )
        file( REMOVE ${WXDL} )

        return()

    endif()

else()
    # wxPython appears to be in the correct place!
    message( STATUS "Found wxPython" )
endif()


#-------------------------------------------------------------------------------
# Get the KiCad Library
if( LIBRARY )

    message( STATUS "Downloading Latest Library Archive..." )
    file( DOWNLOAD ${LIBURL} ${LIBDL} STATUS download_error_list )
    list( GET ${download_error_list} 0 download_error )
    list( GET ${download_error_list} 1 download_error_str )

    #
    # Report a warning that we couldn't update the library!
    #

    if( download_error )

        message( WARNING "${download_error} Failed to download kicad-library source." )
        message( ERROR "${download_error_str}" )

    else()

        file( REMOVE_RECURSE "${SCRDIR}/kicad-library" )
        execute_process( COMMAND ${CMAKE_COMMAND} -E tar xzf ${LIBDL}
                         WORKING_DIRECTORY ${SRCDIR}
                         RESULT_VARIABLE untar_error )

    endif()

endif()

#-------------------------------------------------------------------------------
#
# Get the KiCad Documentation
#
if( DOCUMENTATION )
    if( NOT EXISTS "${SRCDIR}/doc/.bzr" )

        #
        # The directory is not a bazaar version controlled directory, so we must
        # checkout the KiCad Library project
        #

        message( STATUS "Checking out KiCad Documentation source (BZR head)" )
        execute_process(
            COMMAND cmd /c bzr co --lightweight lp:~kicad-developers/kicad/doc
            WORKING_DIRECTORY "${SRCDIR}"
            RESULT_VARIABLE kicad_src_NOT_CO )

        if( kicad_src_NOT_CO )
            message( ERROR "Checking out the Documentation source!" )
        endif()

    else()
        message( STATUS "Checking for KiCad Documentation latest source" )
        execute_process(
                COMMAND cmd /c bzr missing lp:~kicad-developers/kicad/doc
                WORKING_DIRECTORY "${SRCDIR}/doc"
                OUTPUT_VARIABLE output
                ERROR_VARIABLE error
                RESULT_VARIABLE result )

        if( output MATCHES "up to date" OR output MATCHES "extra revisions" )
            message( STATUS "KiCad Documentation is up-to-date." )
        else()
            message( STATUS "Updating KiCad Documentation source from bazaar head" )

            execute_process(
                COMMAND cmd /c bzr up
                WORKING_DIRECTORY "${SRCDIR}/doc"
                ERROR_VARIABLE bzr_up_stderr
                RESULT_VARIABLE kicad_src_NOT_UPDATED )

            if( kicad_src_NOT_UPDATED )
                message( ERROR " Updating Documentation!" )
                message( ERROR " Bazaar said: ${bzr_up_stderr}" )
            endif()
        endif()
    endif()
endif()


#-------------------------------------------------------------------------------
#
# Check for installed BZIP2
#
#

message( STATUS "Checking for BZIP2" )
set( BZ2_FOUND false )

if( EXISTS "${KICADDIR}/bin/libbz2.dll" )
    set( BZ2_FOUND true )
endif()

if( NOT BZ2_FOUND )

    message( STATUS "Downloading BZIP2 Source" )

    file( DOWNLOAD ${BZ2URL} "${SRCDIR}/${BZ2FILE}"
            EXPECTED_MD5 ${BZ2MD5}
            STATUS download_error_list )

    list( GET ${download_error_list} 0 download_error )
    list( GET ${download_error_list} 1 download_error_str )

    # Make sure we always clean away the crud and start again to save
    # hassle when things go wrong
    file( REMOVE_RECURSE "${BZ2SRC}" )
    file( MAKE_DIRECTORY "${BZ2SRC}" )

    execute_process(
            COMMAND ${CMAKE_COMMAND} -E tar xzf "${SRCDIR}/${BZ2FILE}"
            WORKING_DIRECTORY "${BZ2SRC}"
            RESULT_VARIABLE unzip_error )

    file( MAKE_DIRECTORY "${BZ2ROOT}/build" )

    file(   COPY "${ENVDIR}/support/bzip2/CMakeLists.txt"
            DESTINATION "${BZ2ROOT}" )

    message( STATUS "Building BZIP2 Library" )

    # Configure and build the library. Don't bother with error checking.
    # Everything will fail from here on in if this build fails anyway!
    execute_process(
            COMMAND ${CMAKE_COMMAND} -G "CodeBlocks - MinGW Makefiles" ../
            WORKING_DIRECTORY "${BZ2ROOT}/build"
            OUTPUT_VARIABLE configure_output
            ERROR_VARIABLE configure_error
            RESULT_VARIABLE configure_result )

    execute_process(
            COMMAND ${MINGW_MAKE}
            WORKING_DIRECTORY "${BZ2ROOT}/build"
            OUTPUT_VARIABLE make_output
            ERROR_VARIABLE make_error
            RESULT_VARIABLE make_result )

    # Install somewhere that CMake will be able to find when building KiCad
    # The KiCad-Winbuilder setenv.bat adds ${KICADDIR} to the PATH so it
    # will be searched by the find_*() functions.
    file( MAKE_DIRECTORY "${KICADDIR}/bin" )
    file( MAKE_DIRECTORY "${KICADDIR}/lib" )
    file( MAKE_DIRECTORY "${KICADDIR}/include" )
    file( RENAME "${BZ2ROOT}/build/libbz2.dll" "${KICADDIR}/bin/libbz2.dll" )
    file( RENAME "${BZ2ROOT}/build/libbz2.dll.a" "${KICADDIR}/lib/libbz2.dll.a" )
    file( RENAME "${BZ2ROOT}/bzlib.h" "${KICADDIR}/include/bzlib.h" )

endif()

#-------------------------------------------------------------------------------
#
# Check for installed GLEW
#
message( STATUS "Checking for GLEW" )

# Try to find GLEW and when found set this to true
set( GLEW_FOUND false )

if( EXISTS "${GLEWROOT}/lib/libglew32.dll.a" )
    # GLEW is found
    set( GLEW_FOUND true )
endif()

#
# If GLEW cannot be found, make sure the source code has been downloaded.
# Relies on the user not removing the source archive!
#

if( NOT GLEW_FOUND )
    # Check that the source code has been downloaded
    if( NOT EXISTS "${GLEWROOT}" )
        message( STATUS "Downloading ${GLEWDL}" )

        execute_process(
        COMMAND cmd /c bzr co --lightweight ${GLEWBZR} glew-cmake
        WORKING_DIRECTORY "${SRCDIR}"
        RESULT_VARIABLE glew_src_NOT_CO )

        # If the repository cannot be updated, error and quit
        if( glew_src_NOT_CO )
            message( ERROR " Checking out source code!" )
            message( ERROR " Bazaar said: ${bzr_up_stderr}" )

            return()
        endif()
    endif()

    # Set the error flag used below to zero to begin with
    SET( error 0 )

    # Check if GLEW was built before
    if( NOT EXISTS "${GLEWROOT}/build_gcc_release/libglew32.dll.a" )
        message( STATUS "Building GLEW" )

        if( NOT EXISTS "${GLEWROOT}/build_gcc_release" )
            file( MAKE_DIRECTORY "${GLEWROOT}/build_gcc_release" )
        endif()

        execute_process(
            COMMAND ${CMAKE_COMMAND} -G "CodeBlocks - MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release ../
            WORKING_DIRECTORY "${GLEWROOT}/build_gcc_release"
            OUTPUT_FILE "${LOGDIR}/cmake_GLEW_configure_${BUILD}_stdout.log"
            ERROR_FILE "${LOGDIR}/cmake_GLEW_configure_${BUILD}_stderr.log"
            RESULT_VARIABLE glew_build_error )

        execute_process(
            COMMAND ${MINGW_MAKE}
            WORKING_DIRECTORY "${GLEWROOT}/build_gcc_release"
            OUTPUT_FILE "${LOGDIR}/cmake_GLEW_make_${BUILD}_stdout.log"
            ERROR_FILE "${LOGDIR}/cmake_GLEW_make_${BUILD}_stderr.log"
            RESULT_VARIABLE glew_build_error )

    endif()

    # If GLEW cannot be built, error and quit
    if( glew_build_error )
        message( ERROR " Building GLEW" )

        return()
    endif()

    # Everything went fine, so move libraries to the right place
    file( RENAME "${GLEWROOT}/build_gcc_release/libglew32.dll" "${GLEWROOT}/bin/libglew32.dll" )
    file( RENAME "${GLEWROOT}/build_gcc_release/libglew32mx.dll" "${GLEWROOT}/bin/libglew32mx.dll" )
    file( RENAME "${GLEWROOT}/build_gcc_release/libglew32s.a" "${GLEWROOT}/lib/libglew32.a" )
    file( RENAME "${GLEWROOT}/build_gcc_release/libglew32mxs.a" "${GLEWROOT}/lib/libglew32mx.a" )
    file( RENAME "${GLEWROOT}/build_gcc_release/libglew32mx.dll.a" "${GLEWROOT}/lib/libglew32mx.dll.a" )
    file( RENAME "${GLEWROOT}/build_gcc_release/libglew32.dll.a" "${GLEWROOT}/lib/libglew32.dll.a" )

    message( STATUS "GLEW build finished" )
else( NOT GLEW_FOUND )
    # GLEW appears to be built and in the correct place!
    message( STATUS "Found GLEW" )
endif( NOT GLEW_FOUND )


#-------------------------------------------------------------------------------
#
# Check for installed Cairo
#
message( STATUS "Checking for Cairo" )

# Try to find Cairo and when found set this to true
set( CAIRO_FOUND false )

if( EXISTS "${CAIROROOT}/lib/libcairo.dll.a" )
    # Cairo is found
    set( CAIRO_FOUND true )
endif()

#
# If GLEW cannot be found, make sure the source code has been downloaded.
# Relies on the user not removing the source archive!
#

if( NOT CAIRO_FOUND )
    # Check that the source code has been downloaded
    if( NOT EXISTS "${SRCDIR}/cairo/${CAIRODL}" )

        message( STATUS "Downloading ${CAIRODL}" )

        file( DOWNLOAD ${CAIROURL} ${SRCDIR}/cairo/${CAIRODL}
            EXPECTED_MD5 ${CAIROMD5}
            STATUS download_error_list )

        list( GET ${download_error_list} 0 download_error )
        list( GET ${download_error_list} 1 download_error_str )
    endif()

    #
    # Report an error on failure and quit the script as there is nothing else
    # left to do
    #

    if( download_error )
        message( ERROR "${download_error} Failed to download ${CAIRODL} source." )
        message( ERROR "${download_error_str}" )
        return()
    endif()

    #
    # See if we need to decompress the archive, or if it has already been
    # decompressed
    #

    # Set the error flag used below to zero to begin with
    SET( error 0 )

    # Check for the existance of the header directory
    if( NOT EXISTS "${CAIROROOT}/include" )
        message( STATUS "Decompressing Cairo" )

        file( MAKE_DIRECTORY "${CAIROROOT}" )

        execute_process(
            COMMAND ${CMAKE_COMMAND} -E tar xzf ../${CAIRODL}
            WORKING_DIRECTORY ${CAIROROOT}
            RESULT_VARIABLE unzip_error )
    endif()

    #
    # Report an error on failure and quit the script as there is nothing else
    # left to do
    #
    if( unzip_error )
        message( ERROR "  ${unzip_error} " )
        message( ERROR "  Failed to decompress Cairo library. Please" )
        message( ERROR "  run this script again to re-try downloading" )

        # If we failed to decrompress GLEW delete the file in case it was
        # corrupt after a download attempt failed
        message( STATUS "Removing ${CAIRODL}" )
        file( REMOVE ${CAIRODL} )

        return()
    endif()

else()
    # Cairo appears to be built and in the correct place!
    message( STATUS "Found Cairo" )
endif()

#-------------------------------------------------------------------------------
#
# Get the KiCad source code
#

if( NOT EXISTS "${SRCDIR}/kicad/.bzr" )

    # The directory is not a bazaar version controlled directory, so we must
    # checkout the KiCad project

    message( STATUS "Checking out KiCad source code (BZR head)" )
    execute_process(
        COMMAND cmd /c bzr co --lightweight lp:kicad
        WORKING_DIRECTORY "${SRCDIR}"
        RESULT_VARIABLE kicad_src_NOT_CO )

    # If the repository cannot be checked out, error and quit
    if( kicad_src_NOT_CO )
        message( ERROR " Checking out source code!" )
        return()
    endif()
else()

    # Test to see if there is anything new to get, otherwise stop here

    message( STATUS "Checking for KiCad latest source code" )
    execute_process(
            COMMAND cmd /c bzr missing lp:kicad
            WORKING_DIRECTORY "${SRCDIR}/kicad"
            OUTPUT_VARIABLE output
            ERROR_VARIABLE error
            RESULT_VARIABLE result )

    if( NOT FORCEBUILD )
        if( output MATCHES "up to date" OR output MATCHES "extra revisions" )
            message( STATUS "KiCad is up-to-date. Nothing to do" )
            return()
        endif()
    endif()

    # Directory is a bazaar version controlled directory, so we should already
    # have the codebase. Simply update and build

    message( STATUS "Updating KiCad source code from bazaar head" )

    # Do NOT redirect stdout as bazaar could need to ask the user for an auth
    # password. So keep the output directed to the screen. stderr can still
    # be redirected though
    execute_process(
        COMMAND cmd /c bzr up
        WORKING_DIRECTORY "${SRCDIR}/kicad"
        ERROR_VARIABLE bzr_up_stderr
        RESULT_VARIABLE kicad_src_NOT_UPDATED )

    # If the repository cannot be updated, error and quit
    if( kicad_src_NOT_UPDATED )
        message( ERROR " Updating source code!" )
        message( ERROR " Bazaar said: ${bzr_up_stderr}" )
        return()
    endif()
endif()


# ------------------------------------------------------------------------------
#
# Configure with cmake.
#

if( NOT EXISTS "${BUILDDIR}/${BUILD}" )
    file( MAKE_DIRECTORY "${BUILDDIR}/${BUILD}" )
endif()

# There are some dependency issues with the python wrappers, so the easiest way
# to ensure a good build every time is to remove the generated files before each
# build. This lengthens all but initial builds. Unfortunately it's the only way
# to be safe. But the option is here to not bother to delete the files when you
# know nothing has changed.

if( CLEAN_PCBNEW_PYTHON_FILES )

    message( STATUS "Cleaning PCBNEW Python files to ensure good build..." )

    if( EXISTS "${BUILDDIR}/${BUILD}/pcbnew/pcbnew_wrap.cxx" )
        file( REMOVE "${BUILDDIR}/${BUILD}/pcbnew/pcbnew_wrap.cxx" )
    endif()

    if( EXISTS "${BUILDDIR}/${BUILD}/pcbnew/pcbnew.py" )
        file( REMOVE "${BUILDDIR}/${BUILD}/pcbnew/pcbnew.py" )
    endif()

    if( EXISTS "${BUILDDIR}/${BUILD}/pcbnew/_pcbnew.pyd" )
        file( REMOVE "${BUILDDIR}/${BUILD}/pcbnew/_pcbnew.pyd" )
    endif()

    if( EXISTS "${BUILDDIR}/${BUILD}/pcbnew/scripting/pcbnewPYTHON_wrap.cxx" )
        file( REMOVE "${BUILDDIR}/${BUILD}/pcbnew/scripting/pcbnewPYTHON_wrap.cxx" )
    endif()

endif()

# Setup the options to pass to the KiCad build

if( SCRIPTING )
    set( KOPT ${KOPT} -DKICAD_SCRIPTING=ON )
    set( KOPT ${KOPT} -DKICAD_SCRIPTING_MODULES=ON )
    set( KOPT ${KOPT} -DKICAD_SCRIPTING_WXPYTHON=ON )
    set( KOPT ${KOPT} -DPYTHON_ROOT_DIR=${CMAKE_SOURCE_DIR}/env/python )
endif()

if( FPLIBTABLE )
    set( KOPT ${KOPT} -DUSE_FP_LIB_TABLE=ON )
endif()

if( BUILD_GITHUB_PLUGIN )
    set( KOPT ${KOPT} -DBUILD_GITHUB_PLUGIN=ON )
endif()

# Might as well tell the user what options we're using so that they don't find
# out they've got the wrong build at the end of everything!
message( STATUS "Using KiCad Options:" )

foreach( OP ${KOPT} )
    message( STATUS "${OP}" )
endforeach()

# Test to see if the source is already configured. If it is not, we will need to
# configure it now
if( NOT EXISTS "${BUILDDIR}/${BUILD}/Makefile")

    # Insert a new line as bzr does not insert a newline at the end of a branch!
    message( STATUS "\n Configuring KiCad ( ${BUILD} )" )
    execute_process(
        COMMAND ${CMAKE_COMMAND} -G "CodeBlocks - MinGW Makefiles" -DCMAKE_BUILD_TYPE=${BUILD} -DwxWidgets_ROOT_DIR=${WXROOT} ${KOPT} ${SRCDIR}/kicad
        WORKING_DIRECTORY "${BUILDDIR}/${BUILD}"
        OUTPUT_FILE "${LOGDIR}/cmake_${BUILD}_stdout.log"
        ERROR_FILE "${LOGDIR}/cmake_${BUILD}_stderr.log"
        OUTPUT_VARIABLE config_output )

    # Report an error on failure and quit the script as there is nothing else
    # left to do
    if( NOT ${config_output} MATCHES "Build files have been written" )
        message( ERROR
            "Could not configure the KiCad ${BUILD} source code. Cmake failed."
            "See the log file ${LOGDIR}/cmake_${BUILD}_*.log for more details\n" )
        return()
    endif()
endif()


# ------------------------------------------------------------------------------
# Build KiCad (Release Version)

# Get the bazaar revision number so the user knows what revision is being built
execute_process(
    COMMAND cmd /c bzr revno
    WORKING_DIRECTORY "${SRCDIR}/kicad"
    OUTPUT_VARIABLE bzr_revno
    ERROR_VARIABLE bzr_stderr
    RESULT_VARIABLE bzr_revno_result )

# This variable will be filled with the build result after make has executed
set( kicad_NOT_BUILT 1 )

# Build the release version of KiCad - log cmake's output
message( STATUS "Building ${BUILD} version of KiCad revision: ${bzr_revno}" )

execute_process(
    COMMAND ${MINGW_MAKE} ${MAKE_KI_OPTS} rebuild_cache
    WORKING_DIRECTORY "${BUILDDIR}/${BUILD}"
    OUTPUT_FILE "${LOGDIR}/make_${BUILD}_cache_stdout.log"
    ERROR_FILE "${LOGDIR}/make_${BUILD}_cache_stderr.log"
    RESULT_VARIABLE kicad_NOT_BUILT )

if( PROGRESS )
    execute_process(
        COMMAND ${MINGW_MAKE} ${MAKE_KI_OPTS}
        COMMAND ${TEE_COMMAND} ${LOGDIR}/make_${BUILD}.log
        WORKING_DIRECTORY "${BUILDDIR}/${BUILD}"
        ERROR_FILE "${LOGDIR}/make_${BUILD}_stderr.log"
        RESULT_VARIABLE kicad_NOT_BUILT )
else()
    execute_process(
        COMMAND ${MINGW_MAKE} ${MAKE_KI_OPTS}
        WORKING_DIRECTORY "${BUILDDIR}/${BUILD}"
        OUTPUT_FILE "${LOGDIR}/make_${BUILD}_stdout.log"
        ERROR_FILE "${LOGDIR}/make_${BUILD}_stderr.log"
        RESULT_VARIABLE kicad_NOT_BUILT )
endif()


# Display a message if there is a problem with the build rather than just
# silently dropping out
if( kicad_NOT_BUILT )

    message( STATUS "KiCad ${BUILD} was NOT built successfully! Please view the logs" )
    return()

endif()

#-------------------------------------------------------------------------------
# Copy the built binaries to the bin folder along with the dependencies from
# MinGW

message( STATUS "Installing KiCad locally. Use RunKiCad.bat to run this version" )
set( BDIR "${BUILDDIR}/${BUILD}" )

# Copy all the KiCad executables to the runtime directory
file( GLOB_RECURSE INST_EXE "${BDIR}/*.exe" )

foreach( EXE ${INST_EXE} )
    execute_process( COMMAND ${CMAKE_COMMAND} -E copy ${EXE} "${BINDIR}" )
endforeach()

# Copy all the KiCad .kiface executables to the runtime directory
file( GLOB_RECURSE INST_KIFACE "${BDIR}/*.kiface" )

foreach( KIFACE ${INST_KIFACE} )
    execute_process( COMMAND ${CMAKE_COMMAND} -E copy ${KIFACE} "${BINDIR}" )
endforeach()

# Get rid of any test programs, used to test compilation options by the build
if( EXISTS "${BINDIR}/a.exe" )
    file( REMOVE "${BINDIR}/a.exe" )
endif()

# Copy all the wx support library dll's to the runtime directory
file( GLOB_RECURSE INST_DLL "${WXROOT}/*.dll" )

foreach( DLL ${INST_DLL} )
    execute_process( COMMAND ${CMAKE_COMMAND} -E copy ${DLL} "${BINDIR}" )
endforeach()

# Install the demonstration files into the shared directory
file( COPY "${CMAKE_SOURCE_DIR}/src/kicad/demos" DESTINATION "${SHAREDIR}" )

if( SCRIPTING )
    # Copy all the KiCad executables to the runtime directory
    file( GLOB_RECURSE INST_PYD "${BDIR}/*.pyd" )

    if( NOT EXISTS "${BINDIR}/pylib/site-packages" )
        file( MAKE_DIRECTORY "${BINDIR}/pylib/site-packages" )
    endif()

    foreach( PYD ${INST_PYD} )
        execute_process( COMMAND ${CMAKE_COMMAND} -E copy ${PYD} "${BINDIR}/pylib" )
    endforeach()

    # Copy all the KiCad python import modules
    file( GLOB_RECURSE INST_PY "${BDIR}/*.py" )

    foreach( PY ${INST_PY} )
        execute_process( COMMAND ${CMAKE_COMMAND} -E copy ${PY} "${BINDIR}/pylib" )
    endforeach()

    # Install the Python plugins from the source code
    if( NOT EXISTS ${BINDIR}/scipting/plugins )
        file( MAKE_DIRECTORY "${BINDIR}/scripting" )
    endif()

    file( COPY "${SRCDIR}/kicad/pcbnew/scripting/plugins" DESTINATION "${BINDIR}/scripting" )

    # Install python
    file( COPY "${CMAKE_SOURCE_DIR}/env/python/dll" DESTINATION "${BINDIR}" )
    file( COPY "${CMAKE_SOURCE_DIR}/env/python/include" DESTINATION "${BINDIR}" )
    file( COPY "${CMAKE_SOURCE_DIR}/env/python/lib" DESTINATION "${BINDIR}" )
    file( COPY "${CMAKE_SOURCE_DIR}/env/python/pylib" DESTINATION "${BINDIR}" )
    file( COPY "${CMAKE_SOURCE_DIR}/env/python/libpython2.7.dll" DESTINATION "${BINDIR}" )
    file( COPY "${CMAKE_SOURCE_DIR}/env/python/python.exe" DESTINATION "${BINDIR}" )

    # Install wxPython
    file( COPY "${WXROOT}/wxpython/wx-${WXVER}-msw/wx" DESTINATION "${BINDIR}/pylib" )

    # Install the template files
    file( COPY "${SRCDIR}/kicad/template" DESTINATION "${SHAREDIR}" )

    # Fix a couple of things

    # Fix OpenSLL DLL hell - we need to rely on the search order of the python
    # dll loading. So we need .pyd and openssl dlls in the same directory
    file( COPY "${BINDIR}/pylib/_pcbnew.pyd" DESTINATION "${BINDIR}" )
    file( REMOVE "${BINDIR}/pylib/_pcbnew.pyd" )

    # The readline module causes python to quit immediately when being run
    # with an interactive session, so rename it to stop it loading which is
    # harmless
    file( RENAME "${BINDIR}/dll/readline.pyd" "${BINDIR}/dll/_readline.pyd" )
endif()

# Install the documentation if it's enabled
if( DOCUMENTATION )
    file( COPY "${SRCDIR}/doc/doc/help" DESTINATION "${DOCDIR}" )
    file( COPY "${SRCDIR}/doc/doc/tutorials" DESTINATION "${DOCDIR}" )
    file( COPY "${SRCDIR}/doc/internat" DESTINATION "${SHAREDIR}" )
endif()

# Install the library if it's enabled
if( LIBRARY )
    file( COPY "${SRCDIR}/kicad-library-master/library" DESTINATION "${SHAREDIR}" )
    file( COPY "${SRCDIR}/kicad-library-master/modules" DESTINATION "${SHAREDIR}" )
    file( COPY "${SRCDIR}/kicad-library-master/template" DESTINATION "${SHAREDIR}" )

    # As standard, lets use the github fp-lib-table if none exists yet.
    if( NOT EXISTS "${SHAREDIR}/template/fp-lib-table" )
        file( RENAME "${SHAREDIR}/template/fp-lib-table.for-github"
                     "${SHAREDIR}/template/fp-lib-table" )
    endif()
endif()

if( BUILD_GITHUB_PLUGIN )
    # Install OpenSSL
    set( OPENSSL_BASE "${SRCDIR}/kicad/.downloads-by-cmake/openssl-1.0.1e" )
    file( COPY "${OPENSSL_BASE}/bin/libcrypto.dll" DESTINATION "${BINDIR}" )
    file( COPY "${OPENSSL_BASE}/bin/libssl.dll" DESTINATION "${BINDIR}" )
endif()

# Install GLEW
file( COPY "${GLEWROOT}/bin/libglew32.dll" DESTINATION "${BINDIR}" )

# Install required runtime libraries for Cairo
message( STATUS "Downloading runtime libraries.." )

# Directory for temporary downloads
set( DOWNLOADDIR ${BINDIR}/tmp )
file( MAKE_DIRECTORY ${DOWNLOADDIR} )

set( ZLIBVER 1.2.5-2 )
if( NOT EXISTS "${BINDIR}/zlib1.dll" )
    message( STATUS "zlib" )
    file(
        DOWNLOAD "http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/zlib_${ZLIBVER}_win32.zip"
        "${DOWNLOADDIR}/zlib.zip" )
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xfz "${DOWNLOADDIR}/zlib.zip"
        WORKING_DIRECTORY "${DOWNLOADDIR}"
        RESULT_VARIABLE check )
    file( RENAME "${DOWNLOADDIR}/bin/zlib1.dll" "${BINDIR}/zlib1.dll" )
endif( NOT EXISTS "${BINDIR}/zlib1.dll" )

if( NOT EXISTS "${BINDIR}/libcairo-2.dll" )
    message( STATUS "cairo" )
    file(
        DOWNLOAD "http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/cairo_${CAIROVER}_win32.zip"
        "${DOWNLOADDIR}/cairo.zip" )
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xfz "${DOWNLOADDIR}/cairo.zip"
        WORKING_DIRECTORY "${DOWNLOADDIR}"
        RESULT_VARIABLE check )
    file( RENAME "${DOWNLOADDIR}/bin/libcairo-2.dll" "${BINDIR}/libcairo-2.dll" )
    file( RENAME "${DOWNLOADDIR}/bin/libcairo-gobject-2.dll" "${BINDIR}/libcairo-gobject-2.dll" )
    file( RENAME "${DOWNLOADDIR}/bin/libcairo-script-interpreter-2.dll" "${BINDIR}/libcairo-script-interpreter-2.dll" )
endif( NOT EXISTS "${BINDIR}/libcairo-2.dll" )

set( LIBPNGVER 1.4.3-1 )
if( NOT EXISTS "${BINDIR}/libpng14-14.dll" )
    message( STATUS "libpng" )
    file(
        DOWNLOAD "http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/libpng_${LIBPNGVER}_win32.zip"
        "${DOWNLOADDIR}/libpng.zip" )
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xfz "${DOWNLOADDIR}/libpng.zip"
        WORKING_DIRECTORY "${DOWNLOADDIR}"
        RESULT_VARIABLE check )
    file( RENAME "${DOWNLOADDIR}/bin/libpng14-14.dll" "${BINDIR}/libpng14-14.dll" )
endif( NOT EXISTS "${BINDIR}/libpng14-14.dll" )

set( FREETYPEVER 2.4.2-1 )
if( NOT EXISTS "${BINDIR}/freetype6.dll" )
    message( STATUS "freetype" )
    file(
        DOWNLOAD "http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/freetype_${FREETYPEVER}_win32.zip"
        "${DOWNLOADDIR}/freetype.zip" )
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xfz "${DOWNLOADDIR}/freetype.zip"
        WORKING_DIRECTORY "${DOWNLOADDIR}"
        RESULT_VARIABLE check )
    file( RENAME "${DOWNLOADDIR}/bin/freetype6.dll" "${BINDIR}/freetype6.dll" )
endif( NOT EXISTS "${BINDIR}/freetype6.dll" )

set( FONTCONFIGVER 2.8.0-2 )
if( NOT EXISTS "${BINDIR}/libfontconfig-1.dll" )
    message( STATUS "fontconfig" )
    file(
        DOWNLOAD "http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/fontconfig_${FONTCONFIGVER}_win32.zip"
        "${DOWNLOADDIR}/fontconfig.zip" )
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xfz "${DOWNLOADDIR}/fontconfig.zip"
        WORKING_DIRECTORY "${DOWNLOADDIR}"
        RESULT_VARIABLE check )
    file( RENAME "${DOWNLOADDIR}/bin/libfontconfig-1.dll" "${BINDIR}/libfontconfig-1.dll" )
endif( NOT EXISTS "${BINDIR}/libfontconfig-1.dll" )

set( EXPATVER 2.0.1-1 )
if( NOT EXISTS "${BINDIR}/libexpat-1.dll" )
    message( STATUS "expat" )
    file(
        DOWNLOAD "http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/expat_${EXPATVER}_win32.zip"
        "${DOWNLOADDIR}/expat.zip" )
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xfz "${DOWNLOADDIR}/expat.zip"
        WORKING_DIRECTORY "${DOWNLOADDIR}"
        RESULT_VARIABLE check )
    file( RENAME "${DOWNLOADDIR}/bin/libexpat-1.dll" "${BINDIR}/libexpat-1.dll" )
endif( NOT EXISTS "${BINDIR}/libexpat-1.dll" )

# Clean the downloads
file( REMOVE_RECURSE ${DOWNLOADDIR} )

#
# If we are using the local MinGW, this is not in the environment path, and so
# we need to copy the MinGW compiled dependencies across to the bin directory
# too. If not using a local copy, MinGW's bin directory (and therefore
# dependencies!) are in the environment path anyway so no need to copy.
#

if( EXISTS "${CMAKE_SOURCE_DIR}/env/mingw/bin" )

execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/env/mingw/bin/libgcc_s_dw2-1.dll" "${BINDIR}" )

execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy "${CMAKE_SOURCE_DIR}/env/mingw/bin/libstdc++-6.dll" "${BINDIR}" )

endif()
