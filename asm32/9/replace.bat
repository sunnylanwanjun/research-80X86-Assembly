@echo off
cd.>replace_res.dsp
echo 正在替换文件中的字符串
echo.
for /f "tokens=* delims= " %%r in (vc6debugasm32.dsp) do (
	set str=%%r
	setlocal EnableDelayedExpansion
	set str=!str:Test=MyHHHH!
	echo !str!>>replace_res.dsp
	endlocal
)
set str=
@echo on