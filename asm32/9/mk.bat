@echo off
cls



if "%myFirstRun%" == "" ( ..\begin.bat
	set myFirstRun=false
)
del *.exe
del *.ilk
del *.pdb

set extension=.exe
set /a myEXE=0
set fullName=%myEXE%%extension%
 :check
 if exist %fullName% ( 
	set /a myEXE=myEXE+1
	set fullName=!myEXE!%extension%
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

