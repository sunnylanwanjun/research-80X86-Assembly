.386
.model flat,stdcall
option casemap:none
;预定义

;头文件
include		windows.inc   	;常量定义
include		kernel32.inc  	;GetModuleHandle ExitProcess 的定义
includelib	kernel32.lib	
include		user32.inc	;EndDialog DialogBoxParam 的定义
includelib	user32.lib
include		InitConsole.asm
include		_CmdLine.asm
		.data?
szBuffer1	db	4096 dup (?)
szOutput	db	4096 dup (?)

		.const
szFormat1	db	'exe name:%s',0dh,0ah
		db	'arg num:%d',0dh,0ah,0
szFormat2	db	'arg[%d]:%s',0dh,0ah,0
;代码
.code
_Main 	proc	uses ebx esi
	LOCAL	argNum
	invoke	GetModuleFileName,0,addr szBuffer1,sizeof szBuffer1
	invoke	_argc
	mov	argNum,eax
	invoke	wsprintf,addr szOutput,addr szFormat1,addr szBuffer1,argNum
	invoke	_WriteConsole,addr szOutput,0
	
	xor	esi,esi
	.while	esi<argNum
		invoke	_argv,esi,addr szBuffer1,sizeof szBuffer1
		invoke	wsprintf,addr szOutput,addr szFormat2,esi,addr szBuffer1	
		invoke	_WriteConsole,addr szOutput,0
		inc 	esi
	.endw
	
	ret
_Main endp
start:
	invoke	_InitConsole
	invoke	_Main
	invoke	_ReadConsole
	invoke	ExitProcess,NULL
end start
