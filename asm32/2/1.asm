.386  
.model flat,stdcall
option casemap:none
;>>>>>>>>>>>>>>>>
; 宏
;>>>>>>>>>>>>>>>>
DEBUG equ 1
;>>>>>>>>>>>>>>>>
; Include 文件定义
;>>>>>>>>>>>>>>>>
include windows.inc
include user32.inc
include kernel32.inc
includelib user32.lib
includelib kernel32.lib
;>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>
	.data
szText db 'Hello world',0
szCaption db 'Test',0
	.data?
	.const
	.stack
;>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>
	.code
start:
	.if eax && (ebx >= 3) || !(ecx <= 2)
		mov esi,1
	.elseif edx
		mov esi,2
	.endif
;	if DEBUG
;		invoke MessageBox,NULL,addr szText,addr szCaption,MB_OK
;	endif
end start