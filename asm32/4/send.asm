.386
.model flat,stdcall
option casemap:none
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
.data
.data?
hInstance	dd ?
hWinMain  	dd ?
szBuffer  	db 256 dup (?) 
stDataCopy 	COPYDATASTRUCT <> 
.const
szClassName     db 'MyClass',0
szOtherText     db 'Text Send To Other Window',0
szTipWord	db 'Please press btn ,param addr is %d:',0
szTipReturn 	db 'SendMessage has return',0
;-------------------
; code
;-------------------
.code
_WinMain proc
	LOCAL	stWndClass:WNDCLASSEX
	LOCAL 	stMsg:MSG
	LOCAL	hWnd
	
	invoke FindWindow,addr szClassName,NULL
	.if eax
		mov hWnd,eax
		invoke wsprintf,addr szBuffer,addr szTipWord,addr szOtherText
		invoke MessageBox,NULL,addr szBuffer,NULL,MB_OK
		mov stDataCopy.cbData,sizeof szOtherText
		mov stDataCopy.lpData,offset szOtherText
		;invoke SendMessage,hWnd,WM_SETTEXT,0,addr szOtherText
		invoke SendMessage,hWnd,WM_COPYDATA,hWnd,addr stDataCopy
		invoke MessageBox,NULL,addr szTipReturn,NULL,MB_OK
	.endif
	invoke ExitProcess,0
	ret

_WinMain endp

start:
	call _WinMain
	invoke ExitProcess,NULL
end start	