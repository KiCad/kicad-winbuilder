@ECHO OFF

REM Build the KiCad Winbuilder build environment

cmake -Di686=ON -Dx86_64=ON -P BuildEnv.cmake
pause
