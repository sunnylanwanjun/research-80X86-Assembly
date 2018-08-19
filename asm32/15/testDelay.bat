@echo off
set /a test=0

setlocal enabledelayedexpansion
for /l %%a in ( 1,1,10 ) do (
	set /a test=test+1
	echo !test!
)
endlocal
@echo on