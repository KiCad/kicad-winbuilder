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

REM Remember the directory we started in so we can return to it before exiting
REM the script
set CALLDIR=%CD%

call %CD%\setenv.bat
cd kicad\bin

REM Tell the KiCad application manager where it can find it's executables:
SET KICAD=%CALLDIR%\kicad

REM Tell python where it's home is located:
SET PYTHONHOME=%CD%
SET PYTHONPATH=%CD%

REM Tell PCBNEW where to look on github when using the github footprint
REM libraries
SET KIGITHUB=https://github.com/KiCad

REM KiCad stores some files in the user profile. Separate this from our real
REM system so that we don't contaminate a system-wide install with the
REM KiCad-Winbuilder install
REM Unfortunately this doesn't work because wxWidgets uses the CSIDL_APPDATA
REM approach which is managed by Windows and is not available through an
REM environment variable that we can change.
REM SET USERPROFILE=%CD%\profile\userprofile
REM SET APPDATA=%USERPROFILE%\AppData\Roaming
REM SET CSIDL_APPDATA=%APPDATA%

REM Run KiCad
start .\kicad.exe

REM Back to the original directory for a sane exit
cd %CALLDIR%
