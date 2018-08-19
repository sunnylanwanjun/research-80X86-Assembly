.386
.model flat,stdcall
option casemap:none
;-------------------
; define
;-------------------
include rcdef.inc
dwOriginSize	equ	1000000
dwNewSize	equ     100
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
hWinMain	dd	?
dwTotalMemory	dd	?
dwCount		dd	?
ifCanQuit	dd	?

		.const
szInfo		db	'无法继续申请 1MB 大小的内存!',0

;-------------------
; code
;-------------------
.code
_ThreadProc proc lParam
	LOCAL	lcLastMem
	
	mov ifCanQuit,FALSE
	invoke GlobalAlloc,GMEM_ZEROINIT or GMEM_MOVEABLE,dwOriginSize
	mov lcLastMem,eax
	
	inc dwCount
	add dwTotalMemory,dwOriginSize
	.repeat
		; methord 1
;		push lcLastMem
;		invoke GlobalAlloc,GMEM_ZEROINIT or GMEM_MOVEABLE,dwOriginSize
;		mov lcLastMem,eax
;		.if eax
;			inc dwCount
;			add dwTotalMemory,dwOriginSize
;		.endif
;		pop eax
;		invoke GlobalReAlloc,eax,dwNewSize,GMEM_ZEROINIT or GMEM_MOVEABLE
;		sub dwTotalMemory,dwOriginSize-dwNewSize
		
		; methord 2
		invoke GlobalReAlloc,lcLastMem,dwNewSize,GMEM_ZEROINIT or GMEM_MOVEABLE
		sub dwTotalMemory,dwOriginSize-dwNewSize
		invoke GlobalAlloc,GMEM_ZEROINIT or GMEM_MOVEABLE,dwOriginSize
		mov lcLastMem,eax
		.if eax
			inc dwCount
			add dwTotalMemory,dwOriginSize
		.endif
		
		invoke SetDlgItemInt,hWinMain,IDC_COUNT,dwCount,FALSE
		invoke SetDlgItemInt,hWinMain,IDC_MEMORY,dwTotalMemory,FALSE
	.until !lcLastMem
	invoke SetDlgItemText,hWinMain,IDC_INFO,addr szInfo
	mov ifCanQuit,TRUE
	ret
_ThreadProc endp
_DlgProc proc uses ebx esi edi,hWnd,uMsg,wParam,lParam  
	LOCAL	lcThreadID
	
	mov eax,uMsg
	.if ax == WM_INITDIALOG
		push hWnd
		pop  hWinMain
		invoke CreateThread,NULL,0,addr _ThreadProc,NULL,NULL,addr lcThreadID
		invoke CloseHandle,eax
	.elseif ax == WM_CLOSE
		.if ifCanQuit
			invoke EndDialog,hWnd,0
		.endif
	.else
		mov eax,FALSE
		ret
	.endif
	mov eax,TRUE
	ret

_DlgProc endp
start:
	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke DialogBoxParam,hInstance,DLG_MAIN,NULL,_DlgProc,0
	invoke ExitProcess,NULL
end start	