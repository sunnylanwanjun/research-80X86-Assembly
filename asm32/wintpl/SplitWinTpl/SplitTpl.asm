.386
.model flat,stdcall
option casemap:none
;-------------------
; define
;-------------------
include			SplitTpl.inc
;-------------------
; include
;-------------------
include 		windows.inc
include 		gdi32.inc
include 		user32.inc
include 		kernel32.inc
includelib  	gdi32.lib
includelib  	user32.lib
includelib  	kernel32.lib
;-------------------
; data
;-------------------
.data?
hInstance 		dd	?
hWinMain  		dd	?
hMenu	  		dd	?
hSubMenu		dd	?
.const
szClassName     db 'MyClass',0
szCaptionMain   db 'SplitWinTpl',0
;-------------------
; code
;-------------------
.code
_Quit proc
	invoke DestroyWindow,hWinMain
	invoke PostQuitMessage,NULL	
_Quit endp

_WindProc proc uses ebx edi esi hWnd,uMsg,wParam,lParam
	LOCAL	@stPos:POINT
	
	mov eax,uMsg
	.if eax == WM_COMMAND 
		mov eax,wParam
		.if ax == IDM_EXIT
			call _Quit
		.endif
	.elseif eax == WM_SYSCOMMAND
		mov    eax,wParam
		.if ax == SC_CLOSE			 
			invoke _Quit
		.else
			invoke	DefWindowProc,hWnd,uMsg,wParam,lParam
			ret
		.endif
	.elseif eax == WM_CLOSE
		call _Quit
	.elseif eax == WM_RBUTTONDOWN
		invoke GetCursorPos,addr @stPos
		invoke TrackPopupMenu,hSubMenu,TPM_LEFTALIGN,@stPos.x,@stPos.y,0,hWinMain,0
	.else
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret
	.endif
	xor	eax,eax
	ret

_WindProc endp

_WinMain proc
	LOCAL	stWndClass:WNDCLASSEX
	LOCAL 	stMsg:MSG
	LOCAL	hAcc
	
	invoke	GetModuleHandle,NULL
	mov	hInstance,eax
	
	invoke	LoadMenu,hInstance,IDM_MAIN
	mov 	hMenu,eax
	
	invoke	LoadAccelerators,hInstance,IDA_MAIN
	mov	hAcc,eax
	
	invoke	GetSubMenu,hMenu,2
	mov	hSubMenu,eax
	
	invoke	RtlZeroMemory,addr stWndClass,sizeof WNDCLASSEX
	invoke  LoadCursor,0,IDC_ARROW
	mov stWndClass.hCursor,eax
	push	hInstance
	pop	stWndClass.hInstance
	mov	stWndClass.cbSize,sizeof WNDCLASSEX
	mov	stWndClass.lpfnWndProc,_WindProc
	mov	stWndClass.style,CS_HREDRAW or CS_VREDRAW
	mov	stWndClass.hbrBackground,COLOR_WINDOW+1
	mov	stWndClass.lpszClassName,offset szClassName
	invoke	RegisterClassEx,addr stWndClass
	
	invoke	CreateWindowEx,0,offset szClassName,\
		offset szCaptionMain,WS_OVERLAPPEDWINDOW,\
		100,100,600,400,NULL,hMenu,hInstance,NULL
	mov	hWinMain,eax
	
	invoke	ShowWindow,hWinMain,SW_SHOWNORMAL
	invoke	UpdateWindow,hWinMain
	
	.while	TRUE
		invoke GetMessage,addr stMsg,NULL,0,0
		.break .if eax == 0
		invoke TranslateAccelerator,hWinMain,hAcc,addr stMsg
		.if eax == 0
			invoke TranslateMessage,addr stMsg
			invoke DispatchMessage,addr stMsg
		.endif
	.endw
	
	ret

_WinMain endp

start:
	call _WinMain
	invoke ExitProcess,NULL
end start	