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

.data?
szBuffer	db 2048 dup (?)
.const
eName		db 'myName',0	
eValue		db 'myvalue',0
;代码
.code
_Main 	proc	uses ebx
	LOCAL	lpVar
	invoke	_InitConsole
			
	;.while	TRUE
	;	invoke	_ReadConsole
	;	.break	.if ! eax
	;.endw
	
	invoke	SetEnvironmentVariable,addr eName,addr eValue
	invoke	GetEnvironmentVariable,addr eName,offset szBuffer,sizeof szBuffer
	invoke	_ConcatEnter,addr szBuffer
	invoke	_WriteConsole,addr szBuffer,eax
	
;	invoke	GetEnvironmentStrings
;	mov	lpVar,eax
;	mov	ebx,eax
;	.while	TRUE
;		invoke	lstrlen,ebx
;		.break  .if !eax
;		push	eax
;		invoke	_WriteConsole,ebx,eax
;		invoke	_WriteEnter
;		pop	eax
;		inc	eax
;		add	ebx,eax
;	.endw
;	invoke	FreeEnvironmentStrings,lpVar
	ret
_Main endp
start:
	invoke	_Main
	invoke	ExitProcess,NULL
end start
