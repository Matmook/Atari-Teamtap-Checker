@echo off
CLS
SET CURDIR=%~dp0
SET HATARI_PATH=C:\Users\Matmook\Documents\Tools\hatari-2.5.0_windows64

SET PATH=%CURDIR%tools;%HATARI_PATH%;%PATH%
SET PY_CODE_PATH=%CURDIR%tools
SET SOURCE_PATH=%CURDIR%source\
SET RMACPATH=%SOURCE_PATH%

echo Have a nide code my lord!
