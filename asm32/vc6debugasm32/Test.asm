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
include shell32.inc
includelib shell32.lib
includelib gdi32.lib
includelib user32.lib
includelib kernel32.lib
;-------------------
; data
;-------------------
		.data?
hInstance	dd	?
hWinMain	dd	?
hTimerID        dd      ?
hMenu		dd 	?
hIcon    	dd 	?
		.const
szAppName	db      '内存监视',0
szExit		db	'退出',0
szInfo		db	'物理内存总数     %lu MB',0dh,0ah
		db	'空闲物理内存     %lu MB',0dh,0ah
		db	'虚拟内存总数     %lu MB',0dh,0ah
		db	'空闲虚拟内存     %lu MB',0dh,0ah
		db	'已用内存比例     %d%%',0dh,0ah
		db	'————————————————',0dh,0ah
		db	'用户地址空间总数 %lu MB',0dh,0ah
		db	'用户可用地址空间 %lu MB',0dh,0ah,0
		
;-------------------
; code
;-------------------
.code
_WindProc proc uses ebx edi esi hWnd,uMsg,wParam,lParam
	LOCAL	lcszBuffer[1024]:byte
	LOCAL	lcMemStruct:MEMORYSTATUS
	LOCAL   lcNID:NOTIFYICONDATA	
	LOCAL	lcPos:POINT
	LOCAL	lcWndRt:RECT
	LOCAL	lcPosX
	LOCAL	lcPosY
	
	mov eax,uMsg
	.if ax == WM_TIMER
		mov lcMemStruct.dwLength,sizeof MEMORYSTATUS
		invoke GlobalMemoryStatus,addr lcMemStruct		
		push edx
		push ecx
		mov ecx,8
		lea esi,lcMemStruct
		add esi,8
		.while ecx<=32
			mov edx,0
			mov eax,[esi]
			mov ebx,100000h
			div ebx
			mov [esi],eax
			add esi,4
			add ecx,4	
		.endw
		pop ecx
		pop edx
		
		invoke wsprintf,addr lcszBuffer,offset szInfo,\
		       lcMemStruct.dwTotalPhys,
		       lcMemStruct.dwAvailPhys,
		       lcMemStruct.dwTotalPageFile,
		       lcMemStruct.dwAvailPageFile,
		       lcMemStruct.dwMemoryLoad,
		       lcMemStruct.dwTotalVirtual,
		       lcMemStruct.dwAvailVirtual
		invoke SendDlgItemMessage,hWnd,IDC_INFO,WM_SETTEXT,0,addr lcszBuffer
	.elseif ax == WM_COMMAND
		mov eax,wParam
		.if ax == IDCANCEL || ax == IDC_EXIT
			invoke SendMessage,hWnd,WM_CLOSE,0,0
		.endif
	.elseif ax == WM_INITDIALOG
		push hWnd
		pop hWinMain
		
		invoke RtlZeroMemory,addr lcNID,sizeof lcNID
		mov lcNID.cbSize,sizeof NOTIFYICONDATA
		mov eax,hWnd
		mov lcNID.hwnd,eax
		mov lcNID.uID,0
		mov lcNID.uFlags,NIF_ICON or NIF_MESSAGE or NIF_TIP
		mov lcNID.uCallbackMessage,WM_USER
		invoke LoadIcon,hInstance,ICO_MAIN
		mov hIcon,eax
		mov lcNID.hIcon,eax
		invoke lstrcpy,addr lcNID.szTip,addr szAppName
		invoke Shell_NotifyIcon,NIM_ADD,addr lcNID
		invoke CreatePopupMenu
		mov hMenu,eax
		invoke AppendMenu,hMenu,MF_STRING,IDC_EXIT,addr szExit
		
		invoke SetTimer,hWnd,1,1000,NULL
		mov    hTimerID,eax
		invoke RtlZeroMemory,addr lcWndRt,sizeof lcWndRt
		invoke GetClientRect,hWnd,addr lcWndRt
		invoke GetSystemMetrics,SM_CXSCREEN
		sub eax,lcWndRt.right
		mov lcPosX,eax
		invoke GetSystemMetrics,SM_CYSCREEN
		sub eax,lcWndRt.bottom
		sub eax,100
		mov lcPosY,eax
		
		invoke SetWindowPos,hWnd,HWND_TOPMOST,lcPosX,lcPosY,0,0,SWP_NOSIZE
		;invoke SetWindowLong,hWnd,GWL_STYLE,WS_POPUP
		;invoke SetWindowLong,hWnd,GWL_EXSTYLE,WS_EX_TOOLWINDOW
	.elseif ax == WM_USER
		mov eax,lParam
		.if eax == WM_RBUTTONUP
			invoke GetCursorPos,addr lcPos
			invoke TrackPopupMenu,hMenu,TPM_LEFTALIGN,lcPos.x,lcPos.y,FALSE,hWnd,NULL
		.endif
	.elseif ax == WM_CLOSE
		invoke EndDialog,hWnd,0
		invoke KillTimer,NULL,hTimerID
		invoke DeleteObject,hMenu
		invoke DeleteObject,hIcon
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
end start	