@ECHO OFF
REM
REM Part of the KiCad-Winbuilder project
REM
REM Licence:
REM
REM Copyright (C) 2011-2013 Brian Sidebotham
REM
REM This program is free software; you can redistribute it and/or
REM modify it under the terms of the GNU General Public License
REM as published by the Free Software Foundation; either version 2
REM of the License, or (at your option) any later version.
REM
REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM GNU General Public License for more details.
REM
REM You should have received a copy of the GNU General Public License
REM along with this program; if not, you may find one here:
REM http://www.gnu.org/licenses/old-licenses/gpl-2.0.html
REM or you may search the http://www.gnu.org website for the version 2 license,
REM or you may write to the Free Software Foundation, Inc.,
REM 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
REM
REM ----------------------------------------------------------------------------
REM
REM Set-up the build environment.
REM
REM The environment consists of a set of paths to binaries which can be used
REM within the command line environment.
REM


REM ----------------------------------------------------------------------------
REM Set up the path to point to all the binaries required for the environment

REM If we want basic commands from Windows(tm), we'll need to include the basic
REM system directories in the path. It is important that we put these
REM directories at the end of the PATH so that any duplicates in the build
REM environment are used instead of the standard Windows(tm) version
SET PATH_WIN=%WINDIR%\System32

REM Set the base environment path. Makes switching to a new environment easy
SET PATH_ENV_BASE=%CD%\env
SET PATH_PROFILE=%CD%\profile

REM Set the MinGW install binary path
SET PATH_MINGW=%PATH_ENV_BASE%\mingw-w64\mingw32\bin

REM Set the Patch install binary path
SET PATH_PATCH=%PATH_ENV_BASE%\patch\bin

REM The Python Version
SET PATH_PY=%PATH_ENV_BASE%\python
SET PYTHONHOME=%PATH_PY%
SET PYTHONPATH=%PYTHONHOME%;%CD%\build\wxPython-cmake-mswu-gcc_dll_cm-3.0.0-win32\wxpython

REM tee application for win32 - allow streams to be split between console
REM and file
SET PATH_TEE=%PATH_ENV_BASE%\tee

REM SWIG Python bindings generator
SET PATH_SWIG=%PATH_ENV_BASE%\swig\swigwin-2.0.10

REM The excellent Cmake system!
SET PATH_CMAKE=%PATH_ENV_BASE%\cmake\cmake-2.8.12.2-win32-x86\bin

REM Bazaar version control
SET PATH_BZR=%PATH_ENV_BASE%\bazaar

REM libxml2, xslt, iconv and zlib
SET XSLT_VER=1.1.26
SET XML2_VER=2.7.8
SET ICONV_VER=1.9.2
SET ZLIB_VER=1.2.5
SET PATH_XSLT=%PATH_ENV_BASE%\libxslt-%XSLT_VER%.win32\bin
SET PATH_XML2=%PATH_ENV_BASE%\libxml2-%XML2_VER%.win32\bin
SET PATH_ICONV=%PATH_ENV_BASE%\iconv-%ICONV_VER%.win32\bin
SET PATH_ZLIB=%PATH_ENV_BASE%\zlib-%ZLIB_VER%\bin

REM We must set a home for the bazaar environment that we're using. Bazaar may
REM need to be setup for this environment
SET BZR_HOME=%PATH_PROFILE%
SET BZR_PLUGIN_PATH=%PATH_BZR%\plugins
SET BZR=%PATH_BZR%\bzr.exe

REM We must add in the KiCad binary directory to make the _stc.pyd import work!
SET PATH_KICAD=%CD%\kicad\bin
SET PATH_KICAD_ROOT=%CD%\kicad

REM Bazaar must know who you are, just fake something here, but feel free to
REM change it to something meaningful!
%BZR% whoami "John Doe <john.doe@example.com>"

REM ----------------------------------------------------------------------------
REM
REM Generate the bin search path

REM Concatenate the path (Careful of the order of the path entries!)
SET PATH=%PATH_MINGW%;%PATH_CMAKE%;%PATH_BZR%;%PATH_PATCH%;%PATH_PY%;%PATH_SWIG%;%PATH_TEE%;%PATH_XSLT%;%PATH_XML2%;%PATH_ICONV%;%PATH_ZLIB%;%PATH_KICAD%;%PATH_KICAD_ROOT%;%PATH_WIN%


REM ----------------------------------------------------------------------------
REM Make sure this environment doesn't clutter up the not-so-temporary temporary
REM Windows(tm) directories

SET PATH_TEMP=%PATH_PROFILE%\temp
SET TEMP=%PATH_TEMP%

SET PATH_TMP=%PATH_PROFILE%\tmp
SET TMP=%PATH_TMP%
