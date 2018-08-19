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
		.const
szText1		db	'项目1',0
szText2		db	'项目2',0
szText3		db	'项目3',0
szPath		db	'*.*',0
szMessage	db	'选择结果：%s',0
szTitle		db	'您的选择',0
szSelect	db	'您选择了以下的项目：'
szReturn	db	0dh,0ah,0		
;-------------------
; code
;-------------------
.code
_WindProc proc uses ebx edi esi hWnd,uMsg,wParam,lParam
	LOCAL	@szBuffer[128]:byte
	LOCAL   lc_szBuffer1[128]:byte
	LOCAL	lc_szTextBuffer[1024]:byte
	LOCAL	lc_dwSelectCount
	
	mov eax,uMsg
	.if ax == WM_INITDIALOG
		invoke LoadIcon,hInstance,ICO_MAIN
		invoke SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
		invoke SendDlgItemMessage,hWnd,IDC_LISTBOX1,LB_ADDSTRING,0,addr szText1
		invoke SendDlgItemMessage,hWnd,IDC_LISTBOX1,LB_ADDSTRING,0,addr szText2
		invoke SendDlgItemMessage,hWnd,IDC_LISTBOX1,LB_ADDSTRING,0,addr szText3
		invoke SendDlgItemMessage,hWnd,IDC_LISTBOX2,LB_DIR,\
		       DDL_ARCHIVE or DDL_DIRECTORY or DDL_DRIVES or DDL_SYSTEM or \
		       DDL_HIDDEN,\
		       addr szPath
	.elseif ax == WM_COMMAND
		mov eax,wParam
		.if ax == IDCANCEL
			invoke SendMessage,hWnd,WM_CLOSE,0,0
		.elseif ax == IDC_LISTBOX1
			invoke SendMessage,lParam,LB_GETCURSEL,0,0
			mov ebx,eax
			invoke SendMessage,lParam,LB_GETTEXT,ebx,addr @szBuffer
				
			mov eax,wParam
			shr eax,16
			.if ax == LBN_DBLCLK
				invoke MessageBox,hWnd,addr @szBuffer,addr szTitle,MB_OK
			.elseif ax == LBN_SELCHANGE
				invoke SendDlgItemMessage,hWnd,IDC_SEL1,WM_SETTEXT,0,addr @szBuffer
			.endif
		.elseif ax == IDC_LISTBOX2
			mov eax,wParam
			shr eax,16
			.if ax == LBN_SELCHANGE
				invoke SendMessage,lParam,LB_GETSELCOUNT,0,0
				mov ebx,eax
				invoke GetDlgItem,hWnd,IDOK
				invoke EnableWindow,eax,ebx
				;invoke SendDlgItemMessage,hWnd,IDOK,WM_ENABLE,TRUE,0
			.endif
		.elseif ax == IDC_RESET
			invoke GetDlgItem,hWnd,IDC_LISTBOX2
			invoke SendMessage,eax,LB_SETSEL,FALSE,-1
		.elseif ax == IDOK
			;获取选项的数目
			invoke SendDlgItemMessage,hWnd,IDC_LISTBOX2,LB_GETSELCOUNT,0,0
			mov lc_dwSelectCount,eax
			;拷贝选项缓冲区
			invoke SendDlgItemMessage,hWnd,IDC_LISTBOX2,LB_GETSELITEMS,sizeof @szBuffer/4,addr @szBuffer
			lea esi,@szBuffer
			invoke lstrcpy,addr lc_szTextBuffer,addr szSelect
			.while lc_dwSelectCount
				lodsd
				lea ebx,lc_szBuffer1
				invoke SendDlgItemMessage,hWnd,IDC_LISTBOX2,LB_GETTEXT,eax,ebx
				invoke lstrcat,addr lc_szTextBuffer,addr szReturn				 
				invoke lstrcat,addr lc_szTextBuffer,ebx
				dec lc_dwSelectCount
			.endw
			invoke MessageBox,NULL,addr lc_szTextBuffer,addr szTitle,MB_OK
		.endif
	.elseif ax == WM_CLOSE
		invoke EndDialog,hWnd,0
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