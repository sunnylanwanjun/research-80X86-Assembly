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
hInstance	dd	?
nIdTimer        dd      ?
hWinMain        dd      ?
hIcon1		dd	?
hIcon2		dd 	?
		.const
		
;-------------------
; code
;-------------------
.code
_TimerProc proc hWnd,uMsg,nEventId,nTime
	pushad
	invoke GetDlgItemInt,hWinMain,IDC_COUNT,eax,FALSE
	inc eax
	invoke SetDlgItemInt,hWinMain,IDC_COUNT,eax,FALSE
	popad
	ret

_TimerProc endp
_WindProc proc uses ebx edi esi hWnd,uMsg,wParam,lParam
	
	mov eax,uMsg
	.if ax == WM_TIMER
		mov eax,wParam
		.if eax == ID_TIMER1
			mov eax,hIcon1
			xchg eax,hIcon2
			mov hIcon1,eax
			invoke SendDlgItemMessage,hWnd,IDC_SETICON,STM_SETIMAGE,IMAGE_ICON,hIcon1
		.elseif eax == ID_TIMER2
			invoke MessageBeep,-1
		.endif
	.elseif ax == WM_INITDIALOG
		push hWnd
		pop hWinMain
		
		invoke SetTimer,hWnd,ID_TIMER1,250,NULL
		invoke SetTimer,hWnd,ID_TIMER2,1000,NULL
		invoke SetTimer,NULL,NULL,1200,_TimerProc
		mov nIdTimer,eax
		
		invoke LoadIcon,hInstance,ICO_1
		mov hIcon1,eax
		invoke LoadIcon,hInstance,ICO_2
		mov hIcon2,eax
		invoke SendDlgItemMessage,hWnd,IDC_SETICON,STM_SETIMAGE,IMAGE_ICON,hIcon1
		invoke SendMessage,hWnd,WM_SETICON,ICON_BIG,hIcon1
	.elseif ax == WM_CLOSE
		invoke EndDialog,hWnd,0
		invoke KillTimer,hWnd,ID_TIMER1
		invoke KillTimer,hWnd,ID_TIMER2
		invoke KillTimer,NULL,nIdTimer
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