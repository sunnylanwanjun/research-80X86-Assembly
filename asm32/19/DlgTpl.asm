.386
.model flat,stdcall
option casemap:none
;-------------------
; define
;-------------------
include DlgTpl.inc

ID_STATUSBAR	equ	1
ID_EDIT		equ	2

;-------------------
; include
;-------------------
include windows.inc
include gdi32.inc
include user32.inc
include kernel32.inc
include comctl32.inc
includelib gdi32.lib
includelib user32.lib
includelib kernel32.lib
includelib comctl32.lib
;-------------------
; data
;-------------------
		.data?
hInstance	dd	?
hWinMain	dd	?
hWinStatus	dd	?
hWinEdit	dd	?
lpsz1		dd	?
lpsz2		dd	?

		.const
szClass		db	'EDIT',0
szFormat0	db	'%02d:%02d:%02d',0
szFormat1	db	'字节数:%d',0
sz1		db	'插入',0
sz2		db	'改写',0
dwStatusWidth	dd	60,140,172,-1
dwMenuHelp	dd	0,IDM_MENUHELP,0,0
szTestWord	db	'第一区初始化文字',0
;-------------------
; code
;-------------------
.code
_WindProc proc uses ebx edi esi hWnd,uMsg,wParam,lParam
	mov eax,uMsg
	.if	eax == WM_INITDIALOG
		push	hWnd
		pop	hWinMain
		invoke	LoadIcon,hInstance,ICO_MAIN
		invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
		
		invoke	CreateStatusWindow,WS_CHILD or WS_VISIBLE or \
			SBARS_SIZEGRIP or CCS_TOP or CCS_RISIZE,addr szTestWord,hWinMain,ID_STATUSBAR
		mov	hWinStatus,eax
		
	.elseif eax == WM_CLOSE
		invoke EndDialog,hWnd,0
	.elseif eax == WM_COMMAND
		mov eax,wParam
		.if ax == IDOK
			invoke SendMessage,hWnd,WM_CLOSE,0,0
		.endif
	.else
		mov eax,FALSE
		ret
	.endif
	mov eax,TRUE
	ret

_WindProc endp

_WinMain proc
	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke DialogBoxParam,hInstance,DLG_MAIN,\
	       NULL,addr _WindProc,NULL
	ret

_WinMain endp

start:
	call _WinMain
	invoke ExitProcess,NULL
end start	