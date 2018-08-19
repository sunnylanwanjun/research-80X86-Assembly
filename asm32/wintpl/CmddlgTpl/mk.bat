@echo off
cls

if "%myFirstRun%" == "" ( ..\begin.bat
	set myFirstRun=false
)
del *.exe
set extension=.exe
set /a myEXE=0
set fullName=%myEXE%%extension%
 :check
 if exist %fullName% ( 
	set /a myEXE=myEXE+1
	set fullName=%myEXE%%extension%
        goto check
 )

set fullName
nmake EXE=%fullName%
if exist %fullName% (
	%fullName%
)
set myEXE= 
set extension= 
set fullName= 
@echo on

