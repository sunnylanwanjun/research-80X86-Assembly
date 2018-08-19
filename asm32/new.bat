@echo off
if not "%2" == "" ( set /a dirName=%2 ) else ( 
set /a dirName=1
:check
	if exist %dirName% ( set /a dirName=dirName+1
		set dirName
		goto check
	)
)
md %dirName%
set /a srcDir=dirName-1
if not "%1" == "" set srcDir=%1
echo =====copy source way is ========
set srcDir
copy %srcDir%\makefile %dirName%\
copy %srcDir%\mk.bat %dirName%\
copy %srcDir%\debug.bat %dirName%\
copy %srcDir%\*.asm %dirName%\
copy %srcDir%\*.inc %dirName%\
ren %dirName%\%srcDir%.asm %dirName%.asm
echo =====has copy files========
dir %dirName%
set srcDir=
set dirName=
@echo on