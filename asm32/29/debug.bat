@echo off
set debugPath=F:\work\practice\asm32\VC6DebugAsm\
if exist %debugPath%*.asm  del %debugPath%*.asm 
if exist %debugPath%*.inc  del %debugPath%*.inc 
if exist %debugPath%*.rc  del %debugPath%*.rc 
if exist %debugPath%*.ico  del %debugPath%*.ico

if exist *.asm copy *.asm %debugPath%*.asm
if exist *.inc copy *.inc %debugPath%*.inc
if exist *.rc copy *.rc  %debugPath%*.rc
if exist *.ico copy %debugPath%*.ico

for %%i in (*.asm) do (
		type %%i |find "start">nul && ( 
		set objName=%%~ni.asm 
	)
)

rename %debugPath%%objName% VC6DebugAsm.asm 
echo copy file to %debugPath% succeed
@echo on