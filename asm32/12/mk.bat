@echo off
cls

if "%myFirstRun%" == "" ( ..\begin.bat
	set myFirstRun=false
)
if exist *.exe del *.exe
if exist *.ilk del *.ilk
if exist *.pdb del *.pdb

set extension=.exe
set /a myEXE=0
set fullName=%myEXE%%extension%
 :check
 if exist %fullName% ( 
	set /a myEXE=myEXE+1
	setlocal enabledelayedexpansion
	set fullName=!myEXE!%extension%
	endlocal
    goto check
 )

set fullName
set /a myEXE=myEXE-1
nmake EXE=%fullName%

if exist %fullName% (
%fullName%
)

copy *.asm ..\vc6debugasm32\Test.asm
copy *inc ..\vc6debugasm32\*.inc
copy *.rc ..\vc6debugasm32\Test.rc
copy *.ico ..\vc6debugasm32\*.ico

set myEXE= 
set extension= 
set fullName= 
@echo on

