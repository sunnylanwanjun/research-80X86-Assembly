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
hWinMain  	dd ?
hMenu	  	dd ?
hMenu0		dd ?
szBuffer	db 256 dup (?)
hSmall		dd ?
hBig		dd ?
hCur2		dd ?
hCur1		dd ?
szTextBuffer	db 256 dup (?)
.const
szClassName     db 'MyClass',0
szCaptionMain   db 'My first Window',0
szText          db 'Win32 Assembly,Simple and powerful',0
szTIDM_MAIN	db 'TIDM_MAIN',0
szNewItem100	db 'MyNewItem100',0
szNewItem101	db 'MyNewItem101',0
szNewItem102	db 'MyNewItem102',0 
szNewItem103	db 'MyNewItem103',0
szTestHandler	db 'hwnd:%d',0
szTestHandlerTt	db 'handler',0
szAskClose	db 'do you real want to close the window',0
szModifyMenuName db 'ModifyMenuName',0
szCurStrFile	db '1.Ani',0
szTextFormat	db '%d,%d',0
;-------------------
; code
;-------------------
.code
_Quit proc
	invoke MessageBox,hWinMain,addr szAskClose,NULL,MB_YESNO
	.if eax == IDYES 
		invoke DestroyWindow,hWinMain
		invoke PostQuitMessage,NULL	
	.endif
_Quit endp
_DisplayMenuItem proc commandID
	pushad
	invoke wsprintf,addr szBuffer,addr szTestHandler,commandID
	invoke MessageBox,hWinMain,addr szBuffer,addr szTestHandlerTt,MB_OK
	popad
	ret

_DisplayMenuItem endp
_WindProc proc uses ebx edi esi hWnd,uMsg,wParam,lParam

	LOCAL	@stPs:PAINTSTRUCT
	LOCAL	@stRect:RECT
	LOCAL   @hDc
	LOCAL	@stPos:POINT
	LOCAL	@mItemInfo:MENUITEMINFO
	
	mov eax,uMsg
	.if	eax == WM_CREATE
		invoke	LoadIcon,hInstance,ICO_SMALL
		mov	hSmall,eax
		invoke  LoadIcon,hInstance,ICO_BIG
		mov     hBig,eax
		invoke  LoadCursor,hInstance,CUR_2
		mov     hCur2,eax
		invoke  LoadCursorFromFile,addr szCurStrFile
		mov	hCur1,eax
		invoke  SendMessage,hWnd,WM_COMMAND,IDM_SMALL,NULL
		invoke	SendMessage,hWnd,WM_COMMAND,IDM_CUR1,NULL
		;invoke  wsprintf,addr szTextBuffer,addr szTextFormat,hWnd,hWinMain
		;invoke  MessageBox,NULL,addr szTextBuffer,NULL,MB_OK
	.elseif eax == WM_COMMAND 
		mov eax,wParam
		.if ax == IDM_BIG 
			invoke CheckMenuRadioItem,hMenu,IDM_BIG,IDM_SMALL,eax,MF_BYCOMMAND
			invoke SendMessage,hWnd,WM_SETICON,ICON_BIG,hBig
		.elseif ax == IDM_SMALL 
			invoke CheckMenuRadioItem,hMenu,IDM_BIG,IDM_SMALL,eax,MF_BYCOMMAND
			invoke SendMessage,hWnd,WM_SETICON,ICON_BIG,hSmall
		.elseif	ax==IDM_CUR2
			invoke CheckMenuRadioItem,hMenu,IDM_CUR1,IDM_CUR2,eax,MF_BYCOMMAND
			invoke SetClassLong,hWinMain,GCL_HCURSOR,hCur2
		.elseif ax==IDM_CUR1 
			invoke CheckMenuRadioItem,hMenu,IDM_CUR1,IDM_CUR2,eax,MF_BYCOMMAND
			invoke SetClassLong,hWinMain,GCL_HCURSOR,hCur1
		.elseif ax == IDM_EXIT
			call _Quit
		.endif
	.elseif eax == WM_CLOSE
		call _Quit
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
	
	invoke	RtlZeroMemory,addr stWndClass,sizeof WNDCLASSEX
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