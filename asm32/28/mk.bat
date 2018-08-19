@echo off
cls

if "%myFirstRun%" == "" ( ..\begin.bat
	set myFirstRun=false
)

if exist *.exe del *.exe
for %%i in (*.asm) do (
		type %%i |find "end start">nul && ( 
		if exist *.rc (
		rename *.rc %%~ni.rc )
		set objName=%%~ni.obj 
	)
)

if exist *.rc (

	setlocal EnableDelayedExpansion
	for %%i in (dir /b *.rc) do (set resName=%%~ni.res) 
	nmake /a EXE=0.exe OBJS=%objName% RES=!resName!
	endlocal

) else (
	nmake /a EXE=0.exe OBJS=%objName%
)

set objName=
set resName=

if exist 0.exe (
	0.exe
)

@echo on

