@echo off
cls

if "%myFirstRun%" == "" ( ..\begin.bat
	set myFirstRun=false
)

if exist *.exe del *.exe

set EXEExt=.exe
set ASMExt=.asm
set /a myEXE=0
set fullName=%myEXE%%EXEExt%

 :check
 if exist %fullName% (	
	set /a myEXE=myEXE+1
	set fullName=%myEXE%%EXEExt%
	set
    goto check
 )

set fullName
set /a myEXE=myEXE-1
nmake EXE=%fullName%

if exist %fullName% (
%fullName%
)

if exist *.asm copy *.asm ..\vc6debugasm32\*.asm
del ..\vc6debugasm32\Test.asm
for %%i in (..\vc6debugasm32\*.asm) do (type %%i |find "end start">nul && rename %%i Test.asm)
if exist *.inc copy *inc ..\vc6debugasm32\*.inc
if exist *.rc copy *.rc ..\vc6debugasm32\Test.rc
if exist *.ico copy *.ico ..\vc6debugasm32\*.ico

set myEXE= 
set extension= 
set fullName= 
@echo on

