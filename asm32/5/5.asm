.386
.model flat,stdcall
option casemap:none
;-------------------
; define
;-------------------
IDM_MAIN		equ   2000h
IDM_LOOK 		equ   8193
IDM_TOOL 		equ   8194
IDA_MAIN		equ   2000h
IDM_OPEN		equ   4101h
IDM_OPTION		equ   4102h
IDM_EXIT		equ   4103h
IDM_SETFONT		equ   4201h
IDM_SETCOLOR		equ   4202h
IDM_INACT		equ   4203h
IDM_GRAY		equ   4204h
IDM_BIG			equ   4205h
IDM_SMALL		equ   4206h
IDM_LIST		equ   4207h
IDM_DETAIL		equ   4208h
IDM_TOOLBAR		equ   4209h
IDM_TOOLBARTEXT		equ   4210h
IDM_INPUTBAR		equ   4211h
IDM_STATUSBAR		equ   4212h
IDM_HELP		equ   4301h
IDM_ABOUT		equ   4302h
IDM_MYMAIN 		equ   10000
IDM_MyMenu 		equ   10001
IDM_MyMenuItem0         equ   10002
IDA_TESTACC		equ   1000
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
hSubMenu	dd ?
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
	LOCAL	@hSubMenu
	LOCAL	@stPos:POINT
	LOCAL	@mItemInfo:MENUITEMINFO
	
	mov eax,uMsg
	.if eax == WM_PAINT
		invoke BeginPaint,hWnd,addr @stPs
		mov @hDc,eax
		
		invoke GetClientRect,hWnd,addr @stRect
		invoke DrawText,@hDc,addr szText,-1,\
		       addr @stRect,\
		       DT_SINGLELINE or DT_CENTER or DT_VCENTER
		invoke EndPaint,hWnd,addr @stPs   
	.elseif eax == WM_COMMAND 
		mov eax,wParam
		.if ax == IDM_OPEN
			invoke SetMenu,hWinMain,hMenu0
		.elseif ax == IDA_TESTACC
			invoke _DisplayMenuItem,1234
		.elseif ax == IDM_STATUSBAR
			;invoke MessageBox,NULL,addr szModifyMenuName,NULL,MB_OK
			invoke GetMenuState,hMenu,IDM_TOOLBAR,MF_BYCOMMAND
			;mov eax,MF_GRAYED 
			;or  eax,MF_ENABLED
			.if eax == MF_DISABLED
				mov eax,MF_ENABLED	
			.else
				mov eax,MF_DISABLED
			.endif
			invoke EnableMenuItem,hMenu,IDM_TOOLBAR,eax
		.elseif ax >= IDM_TOOLBAR && ax< IDM_STATUSBAR
			mov ebx,eax
			invoke GetMenuState,hMenu,ax,MF_BYCOMMAND
			.if eax == MF_CHECKED 
				mov eax,MF_UNCHECKED
			.else
				mov eax,MF_CHECKED
			.endif
			invoke CheckMenuItem,hMenu,ebx,eax
		.elseif ax >= IDM_BIG && ax <= IDM_DETAIL 
			invoke CheckMenuRadioItem,hMenu,IDM_BIG,IDM_DETAIL,eax,MF_BYCOMMAND
		.elseif ax == IDM_EXIT
			call _Quit
		.endif
	.elseif eax == WM_CREATE
		invoke AppendMenu,hMenu,0,101,addr szNewItem101
		invoke AppendMenu,hMenu,0,102,addr szNewItem102
		;invoke ModifyMenu,hMenu,1,MF_BYPOSITION,105,addr szModifyMenuName
		;invoke InsertMenu,hMenu,105,MF_BYCOMMAND,100,addr szNewItem100
		
		invoke GetSubMenu,hMenu,3  
		mov    @hSubMenu,eax
		
		invoke RtlZeroMemory,addr @mItemInfo,sizeof @mItemInfo
		mov    @mItemInfo.cbSize,sizeof @mItemInfo
		invoke InsertMenuItem,@hSubMenu,106,TRUE,addr @mItemInfo

		invoke GetSystemMenu,hWnd,FALSE
		mov    @hSubMenu,eax
		invoke AppendMenu,@hSubMenu,0,103,addr szNewItem103
	.elseif eax == WM_SYSCOMMAND
		mov    eax,wParam
		.if ax == 103
			invoke _DisplayMenuItem,ax
		.elseif ax == SC_CLOSE			 
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
	
	invoke  LoadMenu,hInstance,IDM_MYMAIN
	mov	hMenu0,eax
	
	;invoke	LoadMenu,hInstance,addr szTIDM_MAIN
	invoke	LoadMenu,hInstance,IDM_MAIN
	mov 	hMenu,eax
	
	invoke	GetSubMenu,hMenu,2
	mov	hSubMenu,eax
	
	invoke	LoadAccelerators,hInstance,IDA_MAIN
	mov	hAcc,eax
	
	invoke	RtlZeroMemory,addr stWndClass,sizeof WNDCLASSEX
	push	hInstance
	pop	stWndClass.hInstance
	mov	stWndClass.cbSize,sizeof WNDCLASSEX
	mov	stWndClass.lpfnWndProc,_WindProc
	mov	stWndClass.style,CS_HREDRAW or CS_VREDRAW
	;invoke	GetStockObject,BLACK_BRUSH
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
	
	invoke GetMenu,hWinMain
	.if eax != hMenu0 
		invoke DestroyMenu,hMenu0
	.else
		invoke DestroyMenu,hMenu
	.endif
	ret

_WinMain endp

start:
	call _WinMain
	invoke ExitProcess,NULL
end start	