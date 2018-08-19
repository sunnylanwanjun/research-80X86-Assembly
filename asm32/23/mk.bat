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
	nmake EXE=0.exe OBJS=%objName% RES=!resName!
	endlocal

) else (
	nmake EXE=0.exe OBJS=%objName% LINK_FLAG=/subsystem:CONSOLE	
)

if exist *.asm copy *.asm ..\vc6debugasm32\*.asm
del ..\vc6debugasm32\Test.asm
for %%i in (..\vc6debugasm32\*.asm) do (type %%i |find "end start">nul && rename %%i Test.asm)
if exist *.inc copy *inc ..\vc6debugasm32\*.inc
if exist *.rc copy *.rc ..\vc6debugasm32\Test.rc
if exist *.ico copy *.ico ..\vc6debugasm32\*.ico
set objName=
set resName=

if exist 0.exe (
	0.exe
)

@echo on

