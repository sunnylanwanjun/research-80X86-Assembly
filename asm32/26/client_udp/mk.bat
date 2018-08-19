@echo off
cls

set beginDir=..\begin.bat
if not exist %beginDir% set beginDir=..\..\begin.bat

if "%myFirstRun%" == "" ( %beginDir%
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
	nmake /a EXE=0.exe OBJS=%objName% LINK_FLAG=/subsystem:CONSOLE	
)

set vcDir=..\vc6debugasm32\
if not exist %vcDir% set vcDir=..\..\vc6debugasm32_2\
if exist *.asm copy *.asm %vcDir%*.asm
del %vcDir%Test.asm
for %%i in (%vcDir%*.asm) do (type %%i |find "end start">nul && rename %%i Test.asm)
if exist *.inc copy *inc %vcDir%*.inc
if exist *.rc copy *.rc %vcDir%Test.rc
if exist *.ico copy *.ico %vcDir%*.ico

set objName=
set resName=
set vcDir=
set beginDir=

if exist 0.exe (
	0.exe
)

@echo on

