.386
.model flat,stdcall
option casemap:none
;-------------------
; define
;-------------------
include rcdef.inc
;-------------------
; include
;-------------------
include windows.inc
include gdi32.inc
include user32.inc
include kernel32.inc
includelib gdi32.lib
includelib user32.lib
includelib kernel32.lib
;-------------------
; data
;-------------------
.data?
hInstance 	dd ?
;-------------------
; code
;-------------------
.code
_WindProc proc uses ebx edi esi hWnd,uMsg,wParam,lParam

	LOCAL	@stPs:PAINTSTRUCT
	LOCAL	@stRect:RECT
	LOCAL   @hDc
	LOCAL	@stPos:POINT
	LOCAL	@mItemInfo:MENUITEMINFO
	
	mov eax,uMsg
	.if	eax == WM_INITDIALOG
		invoke LoadIcon,hInstance,ICO_MAIN
		invoke SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
		;invoke GetWindow,hWnd,IDOK
		;invoke SetFocus,eax
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