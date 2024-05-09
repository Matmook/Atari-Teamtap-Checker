@echo off

REM create required folders
if not exist "_build" (
	mkdir _build
)

REM cleaning
if exist "_build\main.bin" (
	del _build\main.bin
)

echo ------------------------------------------------------------
echo Compiling ASM sources
rmac -i%RMACPATH% -p -s TeamTC.s -o ..\binary\c\TeamTC.tos
IF %ERRORLEVEL% NEQ 0 ( exit /B 1 )

echo Done
