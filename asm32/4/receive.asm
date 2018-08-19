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
hInstance dd ?
hWinMain  dd ?
szBuffer  db 256 dup (?) 
.const
szClassName     db 'MyClass',0
szCaptionMain   db 'My first Window',0
szText          db 'Win32 Assembly,Simple and powerful',0
szReceiveTitle	db 'Receive Msg',0
szReceiveMsg	db 'param:%08x',0dh,0ah
		db 'text:%s',0dh,0ah,0
szReceiveCopy	db 'text:%s ',0
;-------------------
; code
;-------------------
.code
_WindProc proc uses eax ebx edi esi ,hWnd,uMsg,wParam,lParam

	LOCAL	@stPs:PAINTSTRUCT
	LOCAL	@stRect:RECT
	LOCAL   @hDc
	
	mov eax,uMsg
	.if eax == WM_PAINT
		invoke BeginPaint,hWnd,addr @stPs
		mov @hDc,eax
		
		invoke GetClientRect,hWnd,addr @stRect
		invoke DrawText,@hDc,addr szText,-1,\
		       addr @stRect,\
		       DT_SINGLELINE or DT_CENTER or DT_VCENTER
		invoke EndPaint,hWnd,addr @stPs       
	.elseif eax == WM_CLOSE
		invoke DestroyWindow,hWinMain
		invoke PostQuitMessage,NULL
	.elseif eax == WM_SETTEXT
		invoke wsprintf,addr szBuffer,addr szReceiveMsg,lParam,lParam
		invoke MessageBox,NULL,addr szBuffer,addr szReceiveTitle,MB_OK
	.elseif eax == WM_COPYDATA
		mov esi,lParam
		assume esi:ptr COPYDATASTRUCT
		invoke wsprintf,addr szBuffer,addr szReceiveCopy,[esi].lpData
		invoke MessageBox,NULL,addr szBuffer,addr szReceiveTitle,MB_OK
		assume esi:nothing
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
	
	invoke	GetModuleHandle,NULL
	mov	hInstance,eax
	
	invoke	RtlZeroMemory,addr stWndClass,sizeof WNDCLASSEX
	push	hInstance
	pop	stWndClass.hInstance
	mov	stWndClass.cbSize,sizeof WNDCLASSEX
	mov	stWndClass.lpfnWndProc,_WindProc
	mov	stWndClass.style,CS_HREDRAW or CS_VREDRAW
	invoke	GetStockObject,BLACK_BRUSH
	mov	stWndClass.hbrBackground,eax;COLOR_WINDOW+1
	mov	stWndClass.lpszClassName,offset szClassName
	invoke	RegisterClassEx,addr stWndClass
	
	invoke	CreateWindowEx,WS_EX_CLIENTEDGE,offset szClassName,\
		offset szCaptionMain,WS_OVERLAPPEDWINDOW,\
		100,100,600,400,NULL,NULL,hInstance,NULL
	mov	hWinMain,eax
	
	invoke	ShowWindow,hWinMain,SW_SHOWNORMAL
	invoke	UpdateWindow,hWinMain
	
	.while	TRUE
		invoke GetMessage,addr stMsg,NULL,0,0
		.break .if eax == 0
		;invoke	PeekMessage,addr stMsg,NULL,0,0,PM_REMOVE
		;.if eax 
			;.break .if stMsg.message == WM_QUIT 
			invoke TranslateMessage,addr stMsg
			invoke DispatchMessage,addr stMsg
		;.endif
	.endw
	
	ret

_WinMain endp

start:
	call _WinMain
	invoke ExitProcess,NULL
end start	