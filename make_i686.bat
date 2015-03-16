@ECHO OFF

REM Build the KiCad Winbuilder build environment

cmake -Di686=ON -P BuildEnv.cmake
pause
