@ECHO OFF

REM Build the KiCad Winbuilder build environment

cmake -Dx86_64=ON -P BuildEnv.cmake
pause

