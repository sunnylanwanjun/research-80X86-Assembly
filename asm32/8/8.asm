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
hBmp1		dd	?
hBmp2		dd	?
dwPos		dd	?

		.const
szText1		db	'Hello, World!',0
szText2		db	'嘿，你看到标题栏变了吗?',0
szText3		db	'自定义',0
szFormat	db 	'%d',0
;-------------------
; code
;-------------------
.code
_WindProc proc uses ebx edi esi hWnd,uMsg,wParam,lParam
	LOCAL szBuffer[256]:byte 
	LOCAL hCustomText
	LOCAL hScroll
	;invoke RtlZeroMemory,addr testStr,sizeof testStr
	
	mov eax,uMsg
	.if	eax == WM_INITDIALOG
		invoke LoadIcon,hInstance,ICO_MAIN
		invoke SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
		
		invoke LoadBitmap,hInstance,IDB_1
		mov    hBmp1,eax
		invoke LoadBitmap,hInstance,IDB_2
		mov    hBmp2,eax
		
		invoke SendDlgItemMessage,hWnd,IDC_TITLETEXT,CB_ADDSTRING,0,addr szText1
		invoke SendDlgItemMessage,hWnd,IDC_TITLETEXT,CB_ADDSTRING,0,addr szText2
		invoke SendDlgItemMessage,hWnd,IDC_TITLETEXT,CB_ADDSTRING,0,addr szText3
		invoke SendDlgItemMessage,hWnd,IDC_TITLETEXT,CB_SETCURSEL,0,0
		invoke GetDlgItem,hWnd,IDC_CUSTOMTEXT
		invoke EnableWindow,eax,FALSE
		
		invoke SendDlgItemMessage,hWnd,IDC_SCROLL,SBM_SETRANGE,0,100
		
		invoke CheckDlgButton,hWnd,IDC_SHOWBMP,BST_CHECKED
		invoke CheckDlgButton,hWnd,IDC_ALOW,BST_CHECKED
		invoke CheckDlgButton,hWnd,IDC_THICKFRAME,BST_CHECKED
	.elseif eax == WM_CLOSE
		invoke EndDialog,hWnd,0
		invoke DeleteObject,hBmp1
		invoke DeleteObject,hBmp2
	.elseif eax == WM_COMMAND
		mov eax,wParam
		.if ax == IDCANCEL
			invoke SendMessage,hWnd,WM_CLOSE,0,0
		.elseif ax == IDOK
;			invoke GetNextDlgTabItem,hWnd,NULL,FALSE
;			invoke GetWindowLong,eax,GWL_ID
;			invoke wsprintf,addr testStr,addr szFormat,eax
;			invoke MessageBox,NULL,addr testStr,NULL,MB_OK
			
			;invoke SendDlgItemMessage,hWnd,IDC_BMP,STM_GETIMAGE,IMAGE_BITMAP,0
			mov	eax,hBmp1
			xchg	eax,hBmp2
			mov	hBmp1,eax

			invoke SendDlgItemMessage,hWnd,IDC_BMP,STM_SETIMAGE,IMAGE_BITMAP,eax
		.elseif ax == IDC_SHOWBMP
			invoke GetDlgItem,hWnd,IDC_BMP
			mov    ebx,eax
			
			;invoke GetDlgCtrlID,ebx
			;invoke wsprintf,addr testStr,addr szFormat,eax
			;invoke MessageBox,NULL,addr testStr,NULL,MB_OK
			;invoke GetWindowLong,ebx,GWL_ID
			;invoke wsprintf,addr testStr,addr szFormat,eax
			;invoke MessageBox,NULL,addr testStr,NULL,MB_OK
			
			invoke IsWindowVisible,eax
			.if eax
				invoke ShowWindow,ebx,SW_HIDE
			.else
				invoke ShowWindow,ebx,SW_SHOW
			.endif
		.elseif ax == IDC_ONTOP
			invoke IsDlgButtonChecked,hWnd,IDC_ONTOP
			.if eax == BST_CHECKED
				;invoke CheckDlgButton,hWnd,IDC_ONTOP,BST_UNCHECKED
				invoke SetWindowPos,hWnd,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
			.else
				;invoke CheckDlgButton,hWnd,IDC_ONTOP,BST_CHECKED
				invoke SetWindowPos,hWnd,HWND_NOTOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
			.endif
		.elseif ax == IDC_ALOW
			invoke IsDlgButtonChecked,hWnd,IDC_ALOW
			.if eax == BST_CHECKED
				mov ebx,TRUE
			.else
				mov ebx,FALSE
			.endif
			
			invoke GetDlgItem,hWnd,IDOK
			invoke EnableWindow,eax,ebx
		.elseif ax == IDC_MODALFRAME
			invoke GetWindowLong,hWnd,GWL_STYLE
			and eax,not WS_THICKFRAME			
			invoke SetWindowLong,hWnd,GWL_STYLE,eax
		.elseif ax == IDC_THICKFRAME
			invoke GetWindowLong,hWnd,GWL_STYLE
			or eax,WS_THICKFRAME
			invoke SetWindowLong,hWnd,GWL_STYLE,eax
		.elseif ax == IDC_TITLETEXT
			shr eax,16
			.if ax == CBN_SELENDOK 
				invoke GetDlgItem,hWnd,IDC_CUSTOMTEXT
				mov    hCustomText,eax
				invoke SendDlgItemMessage,hWnd,IDC_TITLETEXT,CB_GETCURSEL,0,0
				.if eax == 2 
					invoke EnableWindow,hCustomText,TRUE
				.else
					mov ebx,eax
					invoke SendDlgItemMessage,hWnd,IDC_TITLETEXT,CB_GETLBTEXT,ebx,addr szBuffer
					invoke SetWindowText,hWnd,addr szBuffer
					invoke EnableWindow,hCustomText,FALSE
				.endif
			.endif
		.elseif ax == IDC_CUSTOMTEXT
			invoke GetDlgItemText,hWnd,IDC_CUSTOMTEXT,addr szBuffer,sizeof szBuffer
			invoke SetWindowText,hWnd,addr szBuffer
		.endif
	.elseif eax == WM_HSCROLL
		invoke GetDlgItem,hWnd,IDC_SCROLL
		mov hScroll,eax
		mov eax,lParam
		.if eax == hScroll
			mov eax,wParam
			.if ax == SB_LINELEFT
				dec dwPos
			.elseif ax == SB_LINERIGHT
				inc dwPos
			.elseif ax == SB_PAGELEFT
				sub dwPos,10
			.elseif ax == SB_PAGERIGHT
				add dwPos,10
			.elseif ax == SB_THUMBPOSITION || ax == SB_THUMBTRACK
				mov eax,wParam
				shr eax,16
				mov dwPos,eax
			.else
				mov eax,TRUE
				ret
			.endif
			cmp dwPos,0
			jge @F
			mov dwPos,0
			@@:cmp dwPos,100
			jle @F
			mov dwPos,100
			@@:
			invoke SendDlgItemMessage,hWnd,IDC_SCROLL,SBM_SETPOS,dwPos,TRUE
			invoke SetDlgItemInt,hWnd,IDC_VALUE,dwPos,TRUE	
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